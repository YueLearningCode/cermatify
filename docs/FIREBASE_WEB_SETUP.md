# Firebase Web Setup

Kode aplikasi sudah menyiapkan Firebase Auth persistence dan Firebase App Check
untuk web. Langkah berikut harus diselesaikan pada Firebase dan reCAPTCHA Console.

## 1. Authorized Domains

Buka Firebase Console > Authentication > Settings > Authorized domains, lalu
pastikan domain berikut tersedia:

- `localhost` untuk development lokal.
- `yuelearningcode.github.io` untuk GitHub Pages.
- Domain produksi sendiri jika nanti digunakan.

Masukkan hostname saja, tanpa `https://` dan tanpa path `/cermatify/`.

## 2. App Check reCAPTCHA v3

1. Buat situs reCAPTCHA v3 dan izinkan domain `localhost` serta
   `yuelearningcode.github.io`.
2. Salin site key dan secret key yang dihasilkan.
3. Buka Firebase Console > App Check > Apps, pilih aplikasi web Cermatify.
4. Daftarkan provider reCAPTCHA v3 menggunakan **secret key**.
5. Simpan **site key** untuk build Flutter. Site key bersifat publik, tetapi
   secret key tidak boleh masuk repository atau GitHub Actions variable.

Jangan aktifkan enforcement terlebih dahulu. Deploy aplikasi, pantau metrik
App Check untuk Authentication dan Cloud Firestore, lalu aktifkan enforcement
setelah request sah terdeteksi konsisten.

## 3. GitHub Actions

Tambahkan repository variable berikut melalui Settings > Secrets and variables
> Actions > Variables:

```text
FIREBASE_RECAPTCHA_SITE_KEY=<site-key-recaptcha-v3>
```

Workflow akan berhenti sebelum build jika variable ini kosong.

## 4. Menjalankan secara lokal

Development tetap dapat berjalan tanpa site key; App Check dilewati dan pesan
peringatan ditulis ke console. Untuk menguji App Check secara nyata, jalankan:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_RECAPTCHA_SITE_KEY=<site-key-recaptcha-v3> \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Build release web wajib memiliki site key:

```bash
flutter build web --release \
  --base-href /cermatify/ \
  --dart-define=FIREBASE_RECAPTCHA_SITE_KEY=<site-key-recaptcha-v3> \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

## 5. Pengujian penerimaan

- Login customer, mentor, dan admin pada browser.
- Refresh halaman dan pastikan pengguna tetap login.
- Tutup dan buka browser, lalu pastikan sesi masih tersedia.
- Logout, refresh, dan pastikan sesi tidak kembali.
- Registrasikan customer serta mentor baru.
- Periksa Network/Console browser dan pastikan tidak ada error
  `auth/unauthorized-domain`, App Check, atau permission Firestore.
- Setelah enforcement aktif, pastikan request sah tetap berhasil dan request
  tanpa token App Check ditolak.
