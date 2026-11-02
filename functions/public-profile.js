// Keep this explicit allowlist aligned with Flutter and Firestore Rules.
// Never spread private source fields into a public document.
export function publicProfileData(uid, source) {
  const value = (key, fallback) => Object.hasOwn(source, key) ? source[key] : fallback;
  const mentor = source.role === 'mentor';
  return {
    id: uid,
    nama: value('nama', value('namaLengkap', 'Pengguna Cermatify')),
    image: value('image', ''),
    role: value('role', 'customer'),
    status: value('status', 'inactive'),
    accountStatus: value('accountStatus', 'active'),
    verificationStatus: mentor ? value('verificationStatus', 'pending') : '',
    kampus: mentor ? value('kampus', '') : '',
    jurusan: mentor ? value('jurusan', '') : '',
    layanan: mentor ? value('layanan', []) : [],
    linkedin: mentor ? value('linkedin', '') : '',
    bio: mentor ? value('bio', '') : '',
    rating: mentor ? value('rating', 0) : 0,
    totalSessions: mentor ? value('totalSessions', 0) : 0,
  };
}

export async function syncPublicProfile(db, uid, { apply = false } = {}) {
  const sourceRef = db.doc(`users/${uid}`);
  const publicRef = db.doc(`publicProfiles/${uid}`);
  return db.runTransaction(async (tx) => {
    const [source, target] = await Promise.all([tx.get(sourceRef), tx.get(publicRef)]);
    if (!source.exists) return 'missing';
    const expected = publicProfileData(uid, source.data());
    // Compare objects independently of key ordering, including accidental extra keys.
    const same = target.exists && Object.keys(target.data()).length === Object.keys(expected).length &&
      Object.entries(expected).every(([key, val]) => JSON.stringify(target.data()[key]) === JSON.stringify(val));
    if (same) return 'unchanged';
    if (apply) tx.set(publicRef, expected);
    return target.exists ? 'changed' : 'created';
  });
}
