import { FieldValue } from 'firebase-admin/firestore';

const time = () => FieldValue.serverTimestamp();
const amount = (value) => Number.isSafeInteger(value) && value >= 0 ? value : 0;
const available = (user) => amount(user.saldo) + amount(user.playAvailable);

async function requireAdmin(tx, db, uid) {
  const user = (await tx.get(db.doc(`users/${uid}`))).data();
  if (user?.role !== 'admin') throw new Error('admin-required');
}

export async function changePlayOrderStatus(db, uid, orderId, status) {
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(orderId)) throw new Error('invalid-order');
  return db.runTransaction(async (tx) => {
    await requireAdmin(tx, db, uid);
    const ref = db.doc(`orders/${orderId}`);
    const order = (await tx.get(ref)).data();
    if (!order || order.billingProvider !== 'google_play' || order.paymentStatus !== 'paid') throw new Error('order-not-paid');
    if (order.status === status) return;
    const valid = (order.status === 'waiting verification' && ['progress', 'approved', 'rejected'].includes(status)) ||
      (['progress', 'approved'].includes(order.status) && ['completed', 'rejected'].includes(status));
    if (!valid) throw new Error('invalid-transition');
    const hasMentor = order.mentorNet > 0 && order.mentorId !== 'system';
    const mentorRef = hasMentor ? db.doc(`users/${order.mentorId}`) : null;
    const mentor = mentorRef ? (await tx.get(mentorRef)).data() : null;
    const update = { status, updatedAt: time() };
    if (status === 'completed' && hasMentor) {
      if (order.balanceState !== 'pending' || amount(mentor?.playPending) < order.mentorNet) throw new Error('balance-mismatch');
      tx.update(mentorRef, { playPending: FieldValue.increment(-order.mentorNet), playAvailable: FieldValue.increment(order.mentorNet) });
      update.balanceState = 'available';
      tx.create(db.doc(`financeLedger/completed_${orderId}`), { orderId, mentorId: order.mentorId,
        kind: 'service_completed', mentorNet: order.mentorNet, adminId: uid, createdAt: time() });
    }
    if (status === 'rejected') {
      update.paymentStatus = 'refund_requested';
      update.payoutHold = true;
      // Do not assert money refunded until Google confirms it.
      // Pending funds remain unavailable until refund reconciliation completes.
    }
    tx.update(ref, update);
  });
}

export async function reserveWithdrawal(db, uid, input) {
  const { requestId, nominal, namaRekening, nomorRekening } = input ?? {};
  if (typeof requestId !== 'string' || !/^[A-Za-z0-9_-]{16,128}$/.test(requestId) ||
      !Number.isSafeInteger(nominal) || nominal < 20000 ||
      typeof namaRekening !== 'string' || !namaRekening.trim() || namaRekening.length > 200 ||
      typeof nomorRekening !== 'string' || !/^[0-9]{5,40}$/.test(nomorRekening)) throw new Error('invalid-withdrawal');
  const ref = db.doc(`withdraws/${requestId}`);
  await db.runTransaction(async (tx) => {
    const [userDoc, existing] = await Promise.all([tx.get(db.doc(`users/${uid}`)), tx.get(ref)]);
    if (existing.exists) {
      const value = existing.data();
      if (value.mentorId !== uid || value.nominal !== nominal || value.namaRekening !== namaRekening.trim() || value.nomorRekening !== nomorRekening) throw new Error('request-id-reused');
      return;
    }
    const user = userDoc.data();
    if (user?.role !== 'mentor' || user.status !== 'active' || amount(user.playDebt) > 0 || user.playPayoutHold) throw new Error('mentor-unavailable');
    if (available(user) < nominal) throw new Error('insufficient-balance');
    const playAmount = Math.min(amount(user.playAvailable), nominal);
    const legacyAmount = nominal - playAmount;
    tx.update(userDoc.ref, { playAvailable: FieldValue.increment(-playAmount),
      saldo: FieldValue.increment(-legacyAmount), playPayoutReserved: FieldValue.increment(nominal) });
    tx.create(ref, { mentorId: uid, mentorName: user.nama ?? 'Mentor', nominal,
      namaRekening: namaRekening.trim(), nomorRekening, status: 'pending',
      backendReserved: true, playAmount, legacyAmount, createdAt: time(), updatedAt: time() });
    tx.create(db.doc(`financeLedger/withdraw_reserved_${requestId}`), { withdrawalId: requestId, mentorId: uid,
      kind: 'payout_reserved', nominal, createdAt: time() });
  });
  return { withdrawalId: requestId };
}

export async function changeWithdrawalStatus(db, uid, withdrawalId, status, notes = '') {
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(withdrawalId) || !['approved', 'rejected', 'completed'].includes(status) ||
      typeof notes !== 'string' || notes.length > 1000) throw new Error('invalid-request');
  return db.runTransaction(async (tx) => {
    await requireAdmin(tx, db, uid);
    const ref = db.doc(`withdraws/${withdrawalId}`);
    const withdrawal = (await tx.get(ref)).data();
    if (!withdrawal) throw new Error('withdrawal-not-found');
    if (withdrawal.status === status) return;
    if (!((withdrawal.status === 'pending' && ['approved', 'rejected'].includes(status)) ||
        (withdrawal.status === 'approved' && ['completed', 'rejected'].includes(status)))) throw new Error('invalid-transition');
    if (status === 'completed' && !notes.trim()) throw new Error('transfer-reference-required');
    const mentorRef = db.doc(`users/${withdrawal.mentorId}`);
    const user = (await tx.get(mentorRef)).data();
    if (!user || (status !== 'rejected' && (user.playPayoutHold || amount(user.playDebt) > 0))) throw new Error('payout-on-hold');
    const nominal = withdrawal.nominal;
    const reserved = withdrawal.backendReserved === true;
    if (!reserved && withdrawal.status === 'approved' && status === 'rejected') throw new Error('legacy-payout-needs-manual-review');
    const update = { status, adminId: uid, notes: notes.trim(), updatedAt: time() };
    if (!reserved && status === 'approved') {
      // Migrate an old pending request by reserving once when approved.
      if (amount(user.saldo) < nominal) throw new Error('insufficient-balance');
      tx.update(mentorRef, { saldo: FieldValue.increment(-nominal), playPayoutReserved: FieldValue.increment(nominal) });
      Object.assign(update, { backendReserved: true, playAmount: 0, legacyAmount: nominal });
    } else if (reserved && ['rejected', 'completed'].includes(status)) {
      if (amount(user.playPayoutReserved) < nominal) throw new Error('reservation-mismatch');
      const balances = { playPayoutReserved: FieldValue.increment(-nominal) };
      if (status === 'rejected') {
        balances.playAvailable = FieldValue.increment(amount(withdrawal.playAmount));
        balances.saldo = FieldValue.increment(amount(withdrawal.legacyAmount));
      }
      tx.update(mentorRef, balances);
    }
    tx.update(ref, update);
    tx.create(db.doc(`financeLedger/withdraw_${status}_${withdrawalId}`), {
      withdrawalId, mentorId: withdrawal.mentorId, kind: `payout_${status}`,
      nominal, adminId: uid, reference: notes.trim(), createdAt: time(),
    });
  });
}

export async function revokePlayPurchase(db, receiptId, productId) {
  await db.runTransaction(async (tx) => {
    const receiptRef = db.doc(`playPurchases/${receiptId}`);
    const receipt = (await tx.get(receiptRef)).data();
    if (!receipt || receipt.productId !== productId || receipt.revoked) return;
    const orderRef = db.doc(`orders/${receipt.orderId}`);
    const order = (await tx.get(orderRef)).data();
    if (!order) throw new Error('order-not-found');
    const mentorRef = order.mentorNet > 0 && order.mentorId !== 'system' ? db.doc(`users/${order.mentorId}`) : null;
    const mentor = mentorRef ? (await tx.get(mentorRef)).data() : null;
    if (mentorRef && mentor) {
      const net = order.mentorNet;
      if (order.balanceState === 'pending') {
        if (amount(mentor.playPending) < net) throw new Error('pending-mismatch');
        tx.update(mentorRef, { playPending: FieldValue.increment(-net) });
      } else if (order.balanceState === 'available') {
        const debit = Math.min(amount(mentor.playAvailable), net);
        tx.update(mentorRef, { playAvailable: FieldValue.increment(-debit),
          playDebt: FieldValue.increment(net - debit), playPayoutHold: true });
      }
    }
    tx.update(receiptRef, { revoked: true, revokedAt: time() });
    tx.update(orderRef, { paymentStatus: 'refunded_or_cancelled', payoutHold: true, balanceState: 'reversed', updatedAt: time() });
    tx.create(db.doc(`financeLedger/refund_${receipt.orderId}`), {
      orderId: receipt.orderId, kind: 'purchase_revoked', mentorNet: order.mentorNet ?? 0, createdAt: time(),
    });
  });
}
