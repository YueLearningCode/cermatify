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
