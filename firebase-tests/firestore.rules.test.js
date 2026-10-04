import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const projectId = 'demo-cermatify';
let testEnv;

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
    setDoc(
      doc(db, 'users/customer-2'),
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
  await assertSucceeds(updateDoc(userRef, { nama: 'Updated Name' }));
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

test('withdraw requires active mentor, minimum 50000, sufficient balance and account data', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), 'users/mentor-1'), { saldo: 100000 });
  });
  const db = testEnv.authenticatedContext('mentor-1').firestore();
  const withdrawal = {
    mentorId: 'mentor-1', mentorName: 'Mentor', nominal: 50000,
    namaRekening: 'Mentor', nomorRekening: '0123456789', status: 'pending',
    createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
  };
  await assertSucceeds(setDoc(doc(db, 'withdraws/valid'), withdrawal));
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
