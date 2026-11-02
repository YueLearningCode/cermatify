import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { publicProfileData } from '../functions/public-profile.js';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  collection,
  getDocs,
  query,
  where,
  deleteDoc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const projectId = 'demo-cermatify';
let testEnv;

async function createProfile(db, uid, profile) {
  const batch = writeBatch(db);
  batch.set(doc(db, `users/${uid}`), profile);
  batch.set(doc(db, `publicProfiles/${uid}`), publicProfileData(uid, profile));
  return batch.commit();
}

async function updateProfile(db, uid, changes) {
  const previous = (await getDoc(doc(db, `users/${uid}`))).data();
  const batch = writeBatch(db);
  batch.update(doc(db, `users/${uid}`), changes);
  batch.set(doc(db, `publicProfiles/${uid}`), publicProfileData(uid, { ...previous, ...changes }));
  return batch.commit();
}

function userData(id, email, role = 'customer') {
  const data = {
    id,
    nama: 'Test User',
    email,
    noTelp: '08123456789',
    kampus: 'Test Campus',
    kampusId: 'campus-1',
    jurusan: 'Test Major',
    jurusanId: 'major-1',
    semester: '1',
    image: 'https://example.com/profile.png',
    role,
    status: 'active',
    createdAt: serverTimestamp(),
    adultConfirmed: true,
    termsVersion: '2026-11-01',
    termsAcceptedAt: serverTimestamp(),
  };

  if (role === 'mentor') {
    data.verificationStatus = 'pending';
  }

  return data;
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync('../firestore.rules', 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/admin-1'), {
      ...userData('admin-1', 'admin@example.com'),
      role: 'admin',
    });
    await setDoc(doc(db, 'users/customer-1'), {
      ...userData('customer-1', 'customer@example.com'),
      saldo: 1000,
    });
    await setDoc(doc(db, 'users/mentor-1'), {
      ...userData('mentor-1', 'mentor@example.com', 'mentor'),
      verificationStatus: 'verified',
      saldo: 0,
    });
    await setDoc(doc(db, 'layanan/service-1'), {
      name: 'Cermat Paper',
      type: 'paperlink',
      harga: 50000,
    });
    for (const uid of ['admin-1', 'customer-1', 'mentor-1']) {
      await setDoc(doc(db, `publicProfiles/${uid}`), publicProfileData(uid, (await getDoc(doc(db, `users/${uid}`))).data()));
    }
  });
});

after(async () => {
  await testEnv.cleanup();
});

test('unauthenticated visitors cannot read user documents', async () => {
  const db = testEnv.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/customer-1')));
});

test('authenticated user can create only their own customer profile', async () => {
  const db = testEnv
    .authenticatedContext('customer-2', { email: 'customer2@example.com' })
    .firestore();

  await assertSucceeds(
    createProfile(
      db, 'customer-2',
      userData('customer-2', 'customer2@example.com'),
    ),
  );
  await assertFails(
    setDoc(
      doc(db, 'users/customer-3'),
      userData('customer-3', 'customer2@example.com'),
    ),
  );
});

test('new users cannot assign themselves the admin role', async () => {
  const db = testEnv
    .authenticatedContext('attacker-1', { email: 'attacker@example.com' })
    .firestore();

  await assertFails(
    setDoc(
      doc(db, 'users/attacker-1'),
      userData('attacker-1', 'attacker@example.com', 'admin'),
    ),
  );
});

test('customer cannot change protected role or balance fields', async () => {
  const db = testEnv
    .authenticatedContext('customer-1', { email: 'customer@example.com' })
    .firestore();
  const userRef = doc(db, 'users/customer-1');

  await assertFails(updateDoc(userRef, { role: 'admin' }));
  await assertFails(updateDoc(userRef, { saldo: 999999999 }));
  await assertFails(updateDoc(userRef, { nama: 'Updated Name' }));
  await assertSucceeds(updateProfile(db, 'customer-1', { nama: 'Updated Name' }));
});

test('admin can perform protected user updates', async () => {
  const db = testEnv
    .authenticatedContext('admin-1', { email: 'admin@example.com' })
    .firestore();

  await assertSucceeds(
    updateDoc(doc(db, 'users/mentor-1'), {
      verificationStatus: 'verified',
      saldo: 50000,
    }),
  );
});

test('order price must match the trusted service price', async () => {
  const db = testEnv
    .authenticatedContext('customer-1', { email: 'customer@example.com' })
    .firestore();
  const baseOrder = {
    userId: 'customer-1',
    mentorId: 'mentor-1',
    layananId: 'service-1',
    layananType: 'paperlink',
    price: 50000,
    paymentProofUrl:
      'https://res.cloudinary.com/dvxsmpz3m/image/upload/payment.jpg',
    status: 'waiting verification',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };

  await assertSucceeds(setDoc(doc(db, 'orders/order-valid'), baseOrder));
  await assertSucceeds(setDoc(doc(db, 'orders/order-new-cloud'), {
    ...baseOrder,
    paymentProofUrl: 'https://res.cloudinary.com/rgovyuw1/image/upload/payment.jpg',
  }));
  await assertFails(setDoc(doc(db, 'orders/order-untrusted-cloud'), {
    ...baseOrder,
    paymentProofUrl: 'https://res.cloudinary.com/other-cloud/image/upload/payment.jpg',
  }));
  await assertFails(
    setDoc(doc(db, 'orders/order-tampered'), {
      ...baseOrder,
      price: 1,
    }),
  );
});

test('respondent cannot award their own balance or alter questionnaire', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'kuesioners/questionnaire-1'), {
      userId: 'mentor-1',
      status: 'approved',
      signedBy: [],
      answers: [],
    });
  });

  const db = testEnv
    .authenticatedContext('customer-1', { email: 'customer@example.com' })
    .firestore();

  await assertFails(
    updateDoc(doc(db, 'kuesioners/questionnaire-1'), {
      signedBy: ['customer-1'],
    }),
  );
  await assertFails(
    updateDoc(doc(db, 'users/customer-1'), {
      saldo: 1100,
    }),
  );
});

test('only chat room members can read a room', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'chatRooms/customer-1_mentor-1'), {
      roomId: 'customer-1_mentor-1',
      users: ['customer-1', 'mentor-1'],
      lastMessage: '',
    });
  });

  const memberDb = testEnv
    .authenticatedContext('customer-1', { email: 'customer@example.com' })
    .firestore();
  const outsiderDb = testEnv
    .authenticatedContext('customer-2', { email: 'customer2@example.com' })
    .firestore();
  const roomPath = 'chatRooms/customer-1_mentor-1';

  await assertSucceeds(getDoc(doc(memberDb, roomPath)));
  await assertFails(getDoc(doc(outsiderDb, roomPath)));
  assert.ok(true);
});

async function seedChat() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'chatRooms/room-1'), {
      roomId: 'room-1', users: ['customer-1', 'mentor-1'], lastMessage: 'old',
    });
    // Legacy messages have no readAt field.
    await setDoc(doc(db, 'chatRooms/room-1/messages/legacy'), {
      senderId: 'mentor-1', receiverId: 'customer-1', message: 'hello',
      timestamp: serverTimestamp(),
    });
  });
}

test('only incoming message recipient can set readAt without changing content', async () => {
  await seedChat();
  const recipientDb = testEnv.authenticatedContext('customer-1').firestore();
  const senderDb = testEnv.authenticatedContext('mentor-1').firestore();
  const outsiderDb = testEnv.authenticatedContext('customer-2').firestore();
  const path = 'chatRooms/room-1/messages/legacy';
  await assertFails(updateDoc(doc(senderDb, path), { readAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(outsiderDb, path), { readAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(recipientDb, path), {
    readAt: serverTimestamp(), message: 'tampered',
  }));
  await assertFails(updateDoc(doc(recipientDb, path), { readAt: new Date(0) }));
  await assertSucceeds(updateDoc(doc(recipientDb, path), { readAt: serverTimestamp() }));
  const message = (await getDoc(doc(recipientDb, path))).data();
  assert.ok(message.readAt);
  assert.equal(message.message, 'hello');
  await assertFails(updateDoc(doc(recipientDb, path), { readAt: null }));
});

test('self-addressed and already-read new messages are rejected; send batch is atomic', async () => {
  await seedChat();
  const db = testEnv.authenticatedContext('customer-1').firestore();
  const message = {
    senderId: 'customer-1', receiverId: 'mentor-1', message: 'new',
    timestamp: serverTimestamp(), readAt: null,
  };
  await assertFails(setDoc(doc(db, 'chatRooms/room-1/messages/self'), {
    ...message, receiverId: 'customer-1',
  }));
  const invalidBatch = writeBatch(db);
  invalidBatch.update(doc(db, 'chatRooms/room-1'), { lastMessage: 'should not persist' });
  invalidBatch.set(doc(db, 'chatRooms/room-1/messages/forged-read'), {
    ...message, readAt: serverTimestamp(),
  });
  await assertFails(invalidBatch.commit());
  assert.equal((await getDoc(doc(db, 'chatRooms/room-1'))).data().lastMessage, 'old');
  const validBatch = writeBatch(db);
  validBatch.update(doc(db, 'chatRooms/room-1'), { lastMessage: 'new' });
  validBatch.set(doc(db, 'chatRooms/room-1/messages/valid'), message);
  await assertSucceeds(validBatch.commit());
});

test('room identity merge creates absent rooms and preserves existing previews', async () => {
  const db = testEnv.authenticatedContext('customer-1').firestore();
  const room = doc(db, 'chatRooms/new-room');
  const identity = { roomId: 'new-room', users: ['customer-1', 'mentor-1'] };
  await assertSucceeds(setDoc(room, identity, { merge: true }));
  await assertSucceeds(updateDoc(room, { lastMessage: 'keep me' }));
  await assertSucceeds(setDoc(room, identity, { merge: true }));
  assert.equal((await getDoc(room)).data().lastMessage, 'keep me');
});

test('withdraw writes are backend-only; clients cannot forge requests or approvals', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'users/mentor-1'), { saldo: 100000 });
  });
  const db = testEnv.authenticatedContext('mentor-1').firestore();
  const withdrawal = {
    mentorId: 'mentor-1', mentorName: 'Mentor', nominal: 50000,
    namaRekening: 'Mentor', nomorRekening: '0123456789', status: 'pending',
    createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
  };
  await assertFails(setDoc(doc(db, 'withdraws/valid'), withdrawal));
  for (const [id, changes] of Object.entries({
    below: { nominal: 49999 }, above: { nominal: 100001 },
    fraction: { nominal: 50000.5 }, name: { namaRekening: '' },
    account: { nomorRekening: 'abc' }, forged: { status: 'approved' },
  })) {
    await assertFails(setDoc(doc(db, `withdraws/${id}`), { ...withdrawal, ...changes }));
  }
  await assertFails(updateDoc(doc(db, 'withdraws/valid'), { status: 'approved' }));
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'users/mentor-1'), { status: 'inactive' });
  });
  await assertFails(setDoc(doc(db, 'withdraws/inactive'), withdrawal));
  const customerDb = testEnv.authenticatedContext('customer-1').firestore();
  await assertFails(setDoc(doc(customerDb, 'withdraws/customer'), {
    ...withdrawal, mentorId: 'customer-1',
  }));
});

test('Play purchases and catalog are inaccessible to client writes, including admins', async () => {
  for (const user of ['customer-1', 'admin-1']) {
    const db = testEnv.authenticatedContext(user).firestore();
    for (const path of ['playBillingCatalog/paper', 'playPurchaseIntents/intent1', 'playPurchases/receipt1']) {
      await assertFails(setDoc(doc(db, path), { userId: user, enabled: true }));
      await assertFails(getDoc(doc(db, path)));
    }
  }
});

test('admin cannot alter Google Play order or credit it using the legacy client approval', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'orders/play-order'), {
      userId: 'customer-1', mentorId: 'mentor-1', billingProvider: 'google_play',
      paymentStatus: 'paid', price: 75000, status: 'waiting verification',
    });
  });
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  await assertSucceeds(getDoc(doc(admin, 'orders/play-order')));
  await assertFails(updateDoc(doc(admin, 'orders/play-order'), { status: 'progress', paymentStatus: 'paid' }));
});

test('only block owner controls their list and cannot block themselves', async () => {
  const owner = testEnv.authenticatedContext('customer-1').firestore();
  const other = testEnv.authenticatedContext('mentor-1').firestore();
  const path = 'userBlocks/customer-1/blocked/mentor-1';
  await assertSucceeds(getDoc(doc(owner, path)));
  await assertFails(setDoc(doc(other, path), { createdAt: serverTimestamp() }));
  await assertFails(setDoc(doc(owner, 'userBlocks/customer-1/blocked/customer-1'), { createdAt: serverTimestamp() }));
  await assertSucceeds(setDoc(doc(owner, path), { createdAt: serverTimestamp() }));
  await assertFails(getDoc(doc(other, path)));
  await assertFails(deleteDoc(doc(other, path)));
  await assertSucceeds(deleteDoc(doc(owner, path)));
});

test('blocking stops both directions and alternate rooms; unblocking restores messages', async () => {
  await seedChat();
  const customer = testEnv.authenticatedContext('customer-1').firestore();
  const mentor = testEnv.authenticatedContext('mentor-1').firestore();
  const block = doc(customer, 'userBlocks/customer-1/blocked/mentor-1');
  await setDoc(block, { createdAt: serverTimestamp() });
  for (const [db, senderId, receiverId] of [[customer, 'customer-1', 'mentor-1'], [mentor, 'mentor-1', 'customer-1']]) {
    await assertFails(setDoc(doc(db, 'chatRooms/room-1/messages/blocked'), {
      senderId, receiverId, message: 'blocked', timestamp: serverTimestamp(),
    }));
    await assertFails(setDoc(doc(db, 'chatRooms/another'), { roomId: 'another', users: [senderId, receiverId] }));
    await assertFails(updateDoc(doc(db, 'chatRooms/room-1'), { lastMessage: 'blocked preview' }));
  }
  await assertSucceeds(getDoc(doc(customer, 'chatRooms/room-1/messages/legacy')));
  await deleteDoc(block);
  await assertSucceeds(setDoc(doc(mentor, 'chatRooms/room-1/messages/unblocked'), {
    senderId: 'mentor-1', receiverId: 'customer-1', message: 'allowed', timestamp: serverTimestamp(),
  }));
});

function reportData(changes = {}) {
  return { reporterId: 'customer-1', targetId: 'mentor-1', roomId: 'room-1', messageId: 'legacy',
    reason: 'Spam', details: 'Please review', status: 'open', createdAt: serverTimestamp(), ...changes };
}

test('reports reference real participants and messages; outsiders and forgeries fail', async () => {
  await seedChat();
  const db = testEnv.authenticatedContext('customer-1').firestore();
  await assertSucceeds(setDoc(doc(db, 'moderationReports/valid'), reportData()));
  await assertSucceeds(setDoc(doc(db, 'moderationReports/user-only'), reportData({ messageId: '' })));
  for (const changes of [{ reporterId: 'mentor-1' }, { targetId: 'admin-1' }, { messageId: 'missing' },
    { roomId: 'missing' }, { status: 'resolved' }, { reason: 'invalid' }, { details: 'x'.repeat(2001) }, { reviewedBy: 'admin-1' }]) {
    await assertFails(setDoc(doc(db, 'moderationReports/forged'), reportData(changes)));
  }
  const outsider = testEnv.authenticatedContext('outsider').firestore();
  await assertFails(setDoc(doc(outsider, 'moderationReports/outsider'), reportData({ reporterId: 'outsider' })));
});

test('report privacy, evidence immutability, and admin resolution are enforced', async () => {
  await seedChat();
  const reporter = testEnv.authenticatedContext('customer-1').firestore();
  const target = testEnv.authenticatedContext('mentor-1').firestore();
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  const path = 'moderationReports/private';
  await setDoc(doc(reporter, path), reportData());
  await assertSucceeds(getDoc(doc(reporter, path)));
  await assertFails(getDoc(doc(target, path)));
  await assertSucceeds(getDoc(doc(admin, path)));
  const action = { status: 'resolved', notes: 'Reviewed original message; account restricted.',
    reviewedBy: 'admin-1', updatedAt: serverTimestamp() };
  await assertFails(updateDoc(doc(reporter, path), action));
  await assertFails(updateDoc(doc(admin, path), { ...action, notes: '' }));
  await assertFails(updateDoc(doc(admin, path), { ...action, targetId: 'customer-1' }));
  await assertSucceeds(updateDoc(doc(admin, path), action));
  await assertFails(deleteDoc(doc(reporter, path)));
});

test('either account status flag disables new messages and admin moderation writes', async () => {
  await seedChat();
  const mentor = testEnv.authenticatedContext('mentor-1').firestore();
  for (const flag of [{ status: 'inactive', accountStatus: 'active' }, { status: 'active', accountStatus: 'disabled' }]) {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await updateDoc(doc(context.firestore(), 'users/mentor-1'), flag);
    });
    await assertFails(setDoc(doc(mentor, 'chatRooms/room-1/messages/disabled'), {
      senderId: 'mentor-1', receiverId: 'customer-1', message: 'blocked', timestamp: serverTimestamp(),
    }));
  }
  const customer = testEnv.authenticatedContext('customer-1').firestore();
  await setDoc(doc(customer, 'moderationReports/review'), reportData());
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'users/admin-1'), { accountStatus: 'disabled' });
  });
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  await assertFails(updateDoc(doc(admin, 'moderationReports/review'), {
    status: 'resolved', notes: 'not permitted', reviewedBy: 'admin-1', updatedAt: serverTimestamp(),
  }));
});

test('18+ consent is required on registration and cannot be used to escalate role', async () => {
  const db = testEnv.authenticatedContext('new-adult', { email: 'adult@example.com' }).firestore();
  const reference = doc(db, 'users/new-adult');
  for (const changes of [{ adultConfirmed: false }, { termsVersion: 'old' }, { termsAcceptedAt: new Date(0) }]) {
    await assertFails(setDoc(reference, { ...userData('new-adult', 'adult@example.com'), ...changes }));
  }
  await assertSucceeds(createProfile(db, 'new-adult', userData('new-adult', 'adult@example.com')));
  const owner = testEnv.authenticatedContext('customer-1').firestore();
  const consent = { adultConfirmed: true, termsVersion: '2026-11-01', termsAcceptedAt: serverTimestamp() };
  await assertSucceeds(updateDoc(doc(owner, 'users/customer-1'), consent));
  await assertFails(updateDoc(doc(owner, 'users/customer-1'), { ...consent, role: 'admin' }));
});

test('legacy users must accept current terms before sending chat', async () => {
  await seedChat();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'users/customer-1'), { termsVersion: 'old', adultConfirmed: false });
  });
  const db = testEnv.authenticatedContext('customer-1').firestore();
  const message = { senderId: 'customer-1', receiverId: 'mentor-1', message: 'hello', timestamp: serverTimestamp() };
  await assertFails(setDoc(doc(db, 'chatRooms/room-1/messages/before-consent'), message));
  await updateDoc(doc(db, 'users/customer-1'), {
    adultConfirmed: true, termsVersion: '2026-11-01', termsAcceptedAt: serverTimestamp(),
  });
  await assertSucceeds(setDoc(doc(db, 'chatRooms/room-1/messages/after-consent'), message));
});

test('customers and mentors cannot read other private profiles or query their emails', async () => {
  for (const uid of ['customer-1', 'mentor-1']) {
    const db = testEnv.authenticatedContext(uid).firestore();
    const other = uid === 'customer-1' ? 'mentor-1' : 'customer-1';
    await assertSucceeds(getDoc(doc(db, `users/${uid}`)));
    await assertFails(getDoc(doc(db, `users/${other}`)));
    await assertFails(getDocs(query(collection(db, 'users'), where('role', '==', 'mentor'))));
    const profile = (await assertSucceeds(getDoc(doc(db, `publicProfiles/${other}`)))).data();
    for (const field of ['email', 'noTelp', 'saldo', 'adultConfirmed', 'termsAcceptedAt', 'playAvailable']) {
      assert.equal(Object.hasOwn(profile, field), false);
    }
  }
});

test('mentor and support directories are queryable; customer directory and guests are not', async () => {
  const db = testEnv.authenticatedContext('customer-1').firestore();
  for (const role of ['mentor', 'admin']) {
    const result = await assertSucceeds(getDocs(query(collection(db, 'publicProfiles'), where('role', '==', role))));
    assert.equal(result.size, 1);
  }
  await assertFails(getDocs(collection(db, 'publicProfiles')));
  await assertFails(getDocs(query(collection(db, 'publicProfiles'), where('role', '==', 'customer'))));
  await assertFails(getDoc(doc(testEnv.unauthenticatedContext().firestore(), 'publicProfiles/mentor-1')));
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  assert.equal((await assertSucceeds(getDocs(collection(admin, 'users')))).size, 3);
});

test('public profile cannot leak extra fields, impersonate verification, or change another user', async () => {
  const owner = testEnv.authenticatedContext('mentor-1').firestore();
  await assertFails(updateDoc(doc(owner, 'publicProfiles/mentor-1'), { email: 'private@example.com' }));
  await assertFails(updateDoc(doc(owner, 'publicProfiles/mentor-1'), { rating: 5, totalSessions: 900 }));
  await assertFails(updateDoc(doc(owner, 'publicProfiles/customer-1'), { nama: 'forged' }));
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  await assertFails(updateDoc(doc(admin, 'publicProfiles/mentor-1'), { noTelp: '081234' }));
  await assertFails(updateDoc(doc(admin, 'users/mentor-1'), { verificationStatus: 'pending' }));
  await assertSucceeds(updateProfile(admin, 'mentor-1', { verificationStatus: 'pending', status: 'inactive', accountStatus: 'disabled' }));
  const visible = (await getDoc(doc(admin, 'publicProfiles/mentor-1'))).data();
  assert.equal(visible.verificationStatus, 'pending');
  assert.equal(visible.status, 'inactive');
});

test('registration and deletion must keep public and private profiles atomic', async () => {
  const db = testEnv.authenticatedContext('new-user', { email: 'new@example.com' }).firestore();
  const source = userData('new-user', 'new@example.com');
  await assertFails(setDoc(doc(db, 'users/new-user'), source));
  const forged = writeBatch(db);
  forged.set(doc(db, 'users/new-user'), source);
  forged.set(doc(db, 'publicProfiles/new-user'), { ...publicProfileData('new-user', source), email: source.email });
  await assertFails(forged.commit());
  await assertSucceeds(createProfile(db, 'new-user', source));
  const admin = testEnv.authenticatedContext('admin-1').firestore();
  await assertFails(deleteDoc(doc(admin, 'users/new-user')));
  const removal = writeBatch(admin);
  removal.delete(doc(admin, 'users/new-user'));
  removal.delete(doc(admin, 'publicProfiles/new-user'));
  await assertSucceeds(removal.commit());
});
