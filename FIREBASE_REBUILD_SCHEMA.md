# Rekonstruksi Skema Firebase Cermatify

Dokumen ini dibuat dari pembacaan kode Flutter Cermatify. Karena akses Firebase Console lama hilang, data lama tidak bisa dipulihkan dari project Flutter ini. Yang bisa dibuat ulang adalah struktur Firebase baru agar aplikasi dapat berjalan lagi dengan database kosong/baru.

## Ringkasan

Aplikasi memakai:

- Firebase Authentication untuk login/register email dan password.
- Cloud Firestore untuk data aplikasi.
- Cloudinary untuk upload gambar profil dan bukti pembayaran.

Collection Firestore utama:

- `users`
- `kampus`
- `jurusan`
- `layanan`
- `orders`
- `kuesioners`
- `data_diri`
- `withdraws`
- `chatRooms`
- `chatRooms/{roomId}/messages`

## 1. Authentication

Aktifkan provider:

```text
Firebase Console -> Authentication -> Sign-in method -> Email/Password
```

Setiap user yang bisa login harus punya:

1. Akun di Firebase Authentication.
2. Document di Firestore `users/{uid}` dengan Document ID sama seperti UID Authentication.

## 2. Collection `users`

Document ID:

```text
users/{firebaseAuthUid}
```

Contoh user admin:

```json
{
  "id": "UID_ADMIN",
  "nama": "Admin Cermatify",
  "email": "admin@example.com",
  "noTelp": "",
  "kampus": "",
  "kampusId": "",
  "jurusan": "",
  "jurusanId": "",
  "semester": "",
  "image": "",
  "role": "admin",
  "status": "active",
  "saldo": 0,
  "createdAt": "serverTimestamp"
}
```

Contoh user customer:

```json
{
  "id": "UID_CUSTOMER",
  "nama": "User Customer",
  "email": "customer@example.com",
  "noTelp": "08123456789",
  "kampus": "Universitas Contoh",
  "kampusId": "ID_KAMPUS",
  "jurusan": "Informatika",
  "jurusanId": "ID_JURUSAN",
  "semester": "5",
  "image": "",
  "role": "customer",
  "status": "active",
  "saldo": 0,
  "createdAt": "serverTimestamp"
}
```

Contoh user mentor:

```json
{
  "id": "UID_MENTOR",
  "nama": "Mentor Cermat",
  "email": "mentor@example.com",
  "noTelp": "08123456789",
  "kampus": "Universitas Contoh",
  "kampusId": "ID_KAMPUS",
  "jurusan": "Informatika",
  "jurusanId": "ID_JURUSAN",
  "semester": "7",
  "image": "",
  "role": "mentor",
  "mentorRole": "paperlink",
  "layanan": ["Review Paper"],
  "layananIds": ["ID_LAYANAN"],
  "linkedin": "https://linkedin.com/in/username",
  "verificationStatus": "verified",
  "status": "active",
  "saldo": 0,
  "createdAt": "serverTimestamp"
}
```

Nilai penting:

- `role`: `admin`, `customer`, atau `mentor`.
- `verificationStatus` untuk mentor: `pending` atau `verified`.
- Mentor dengan `verificationStatus: pending` tidak bisa login.

## 3. Collection `kampus`

Dipakai untuk dropdown kampus.

Contoh:

```json
{
  "name": "Universitas Contoh",
  "createdAt": "serverTimestamp"
}
```

## 4. Collection `jurusan`

Dipakai untuk dropdown jurusan, terhubung ke `kampus`.

Contoh:

```json
{
  "name": "Informatika",
  "kampusId": "ID_DOCUMENT_KAMPUS",
  "createdAt": "serverTimestamp"
}
```

## 5. Collection `layanan`

Dipakai untuk layanan mentor dan order.

Contoh layanan Paperlink:

```json
{
  "name": "Review Paper",
  "type": "paperlink",
  "harga": 50000,
  "createdAt": "serverTimestamp"
}
```

Contoh layanan Complink:

```json
{
  "name": "Konsultasi Lomba",
  "type": "complink",
  "harga": 75000,
  "createdAt": "serverTimestamp"
}
```

Nilai `type` yang dipakai kode:

- `paperlink`
- `complink`

## 6. Collection `orders`

Dipakai untuk order layanan dan pembayaran kuesioner.

Contoh order layanan:

```json
{
  "userId": "UID_CUSTOMER",
  "mentorId": "UID_MENTOR",
  "layananId": "ID_LAYANAN",
  "layananType": "paperlink",
  "price": 50000,
  "paymentProofUrl": "https://res.cloudinary.com/...",
  "status": "waiting verification",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Contoh order kuesioner:

```json
{
  "userId": "UID_CUSTOMER",
  "mentorId": "UID_ADMIN",
  "layananId": "kuesioner",
  "layananType": "kuesioner",
  "price": 25000,
  "paymentProofUrl": "https://res.cloudinary.com/...",
  "status": "waiting verification",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Status yang dipakai:

- `waiting verification`
- `progress`
- `approved`
- `rejected`
- `completed`

## 7. Collection `kuesioners`

Dipakai untuk kuesioner yang dibuat user.

Contoh:

```json
{
  "userId": "UID_CUSTOMER",
  "orderId": "ID_ORDER",
  "link": "https://forms.gle/contoh",
  "status": "waiting verification",
  "rentangUsia": "18-25 tahun",
  "jenisKelamin": "Laki-laki",
  "tingkatPenghasilan": "Rp 2.000.000 - Rp 5.000.000",
  "pendidikanTerakhir": "S1/D4",
  "answers": [],
  "signedBy": [],
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Field `answers` berisi array object:

```json
[
  {
    "question": "Pertanyaan",
    "answer": "Jawaban"
  }
]
```

Field `signedBy` berisi array UID user yang sudah mengisi/menandatangani.

## 8. Collection `data_diri`

Document ID:

```text
data_diri/{firebaseAuthUid}
```

Dipakai untuk data responden kuesioner.

Contoh:

```json
{
  "userId": "UID_USER",
  "rentangUsia": "18-25 tahun",
  "jenisKelamin": "Perempuan",
  "tingkatPenghasilan": "Rp 2.000.000 - Rp 5.000.000",
  "pendidikanTerakhir": "S1/D4",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

## 9. Collection `withdraws`

Dipakai untuk permintaan withdraw mentor.

Contoh:

```json
{
  "mentorId": "UID_MENTOR",
  "mentorName": "Mentor Cermat",
  "nominal": 50000,
  "namaRekening": "Nama Pemilik Rekening",
  "nomorRekening": "1234567890",
  "status": "pending",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "adminId": null,
  "notes": null
}
```

Status yang dipakai:

- `pending`
- `approved`
- `rejected`
- `completed`

## 10. Collection `chatRooms`

Document ID dibuat dari UID user, UID mentor/admin, dan opsional order ID.

Contoh:

```json
{
  "roomId": "UID_A_UID_B",
  "users": ["UID_A", "UID_B"],
  "orderId": "ID_ORDER",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "lastMessage": "Halo",
  "lastSenderId": "UID_A"
}
```

Subcollection:

```text
chatRooms/{roomId}/messages/{messageId}
```

Contoh message:

```json
{
  "senderId": "UID_A",
  "receiverId": "UID_B",
  "message": "Halo",
  "timestamp": "serverTimestamp",
  "localTime": "2026-06-28T10:00:00.000"
}
```

## Cara Membuat Admin Pertama

1. Buat Firebase project baru.
2. Aktifkan Authentication Email/Password.
3. Tambahkan user admin di Authentication.
4. Copy UID user admin.
5. Buat document baru di Firestore:

```text
users/{UID_ADMIN}
```

6. Isi minimal:

```json
{
  "id": "UID_ADMIN",
  "nama": "Admin Cermatify",
  "email": "admin@example.com",
  "role": "admin",
  "status": "active",
  "image": "",
  "saldo": 0,
  "createdAt": "serverTimestamp"
}
```

7. Login di aplikasi menggunakan email dan password admin tersebut.

## Konfigurasi Flutter ke Firebase Baru

Setelah membuat Firebase project baru, konfigurasi lama di project ini harus diganti:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- konfigurasi web di Firebase

Cara paling rapi adalah memakai FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Lalu pilih project Firebase baru kamu.

## Catatan Penting

- Skema ini adalah hasil rekonstruksi dari kode, bukan export database asli.
- Data lama seperti user, order, chat, dan kuesioner tidak bisa didapat jika akses Firebase lama hilang.
- Jika ingin aplikasi berjalan penuh, buat minimal data awal di `kampus`, `jurusan`, `layanan`, dan satu `users` admin.
