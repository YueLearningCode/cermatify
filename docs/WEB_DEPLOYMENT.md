# Deployment Flutter Web Cermatify

## Firebase Hosting — penyiapan 25 Oktober 2026

Deployment awal berhasil: **https://cermatify.web.app** (alternatif:
https://cermatify.firebaseapp.com). Versi Hosting `a6a8304593f4a2c9` diterbitkan
pada 25 Oktober 2026 sekitar 15.42 WIB. Pemeriksaan HTTPS, kecocokan artefak,
landing dan guard tamu selesai; penerimaan akun nyata/transaksi tetap terpisah.

Hosting disiapkan untuk proyek `cermatify` melalui `.firebaserc` dan bagian
`hosting` di `firebase.json`. Direktori publik adalah `build/web`; routing
fallback menuju `index.html`, dan file direvalidasi melalui `Cache-Control:
no-cache`. Konfigurasi Flutter/Firestore yang sudah ada dipertahankan.

Gunakan Node.js dan Firebase CLI melalui perintah berikut dari root proyek:

```powershell
npx --yes firebase-tools@15.28.1 login
flutter build web --release --no-pub --base-href / --dart-define=CLOUDINARY_CLOUD_NAME=rgovyuw1 --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
npx --yes firebase-tools@15.28.1 deploy --only hosting --project cermatify
```

Base href `/` digunakan untuk alamat Firebase bawaan dan domain root
`cermatify.com`. Perintah deploy hanya menerbitkan Hosting; Firestore Rules dan
layanan lain memerlukan deployment tersendiri bila sudah ditinjau dan siap.

Apabila site key reCAPTCHA sudah tersedia, tambahkan
`--dart-define=FIREBASE_RECAPTCHA_SITE_KEY=<site-key-publik>` pada build. Saat
penyiapan ini site key belum tersedia di environment lokal, sehingga build
mengikuti pengecualian sementara tanpa App Check yang dicatat di `TODO_WEB.md`.
Konfigurasi enforcement tidak diubah oleh deployment Hosting.

Domain `cermatify.com` belum disambungkan pada langkah ini. Konfigurasi DNS,
sertifikat HTTPS domain kustom, Authorized Domains dan kesiapan App Check
dilacak tersendiri. Hasil deployment aktual serta URL dicatat di `TODO_WEB.md`.

Untuk rollback Hosting, pilih versi stabil sebelumnya pada riwayat rilis di
Firebase Console, lalu ulangi smoke test. Jika belum ada rilis sebelumnya,
belum tersedia versi lama untuk dipulihkan.

## Deploy ulang perubahan dari VS Code

1. Simpan perubahan lalu periksa tampilannya melalui Flutter lokal. Hot reload
   memperbarui aplikasi lokal; publikasi Hosting dilakukan melalui build/deploy.
2. Buka Terminal di VS Code dan pastikan direktori aktif adalah
   `E:\laragon\www\cermatify\cermatify` (folder yang memiliki `firebase.json`).
3. Build ulang hasil perubahan dengan konfigurasi root Hosting:

```powershell
& 'E:\develop\flutter\bin\flutter.bat' build web --release --base-href / --dart-define=CLOUDINARY_CLOUD_NAME=rgovyuw1 --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

4. Setelah build berhasil, terbitkan direktori `build/web`:

```powershell
npx.cmd --yes firebase-tools@15.28.1 deploy --only hosting --project cermatify
```

5. Tunggu `Deploy complete!`, kemudian buka ulang situs. Bila tampilan lama masih
   terlihat, coba hard refresh `Ctrl+Shift+R` atau jendela incognito.

Login Firebase CLI dan inisialisasi tidak perlu diulang pada setiap perubahan;
login ulang dilakukan jika sesi kedaluwarsa/dicabut. Jika build gagal, perbaiki
error sebelum menjalankan deploy agar tidak menerbitkan build lama.

Deployment berikutnya memperbarui situs Hosting yang sama. Setelah domain
`cermatify.com` tersambung, pembaruan berlaku pada domain tersebut dan alamat
Firebase bawaan; record DNS tidak perlu dipasang ulang. Pemilik melaporkan
status domain **Minting certificate** pada 25 Oktober 2026; HTTPS/Connected
masih perlu diverifikasi.

Workflow otomatis yang tersedia saat ini menargetkan GitHub Pages. Commit/push
Git saja belum menerbitkan perubahan ke Firebase Hosting; otomatisasi Firebase
dapat disiapkan sebagai pekerjaan terpisah. Perubahan Firestore Rules/functions
pun memerlukan pengujian dan deployment tersendiri, karena perintah di atas
khusus Hosting. Ketika App Check dikonfigurasi, pertahankan site key publiknya
pada setiap build sesuai bagian penyiapan di atas.

## GitHub Pages — workflow yang sudah tersedia

Bagian berikut mendokumentasikan pipeline GitHub Pages yang masih tersedia.
Deployment manual ke Firebase tidak mengubah workflow tersebut.

## Prasyarat GitHub

1. Buka **Settings > Pages** pada repository.
2. Pada **Build and deployment**, pilih **GitHub Actions** sebagai source.
3. Tambahkan Repository Variables berikut:
   - `CLOUDINARY_UPLOAD_PRESET`: nama restricted unsigned upload preset.
   - `FIREBASE_RECAPTCHA_SITE_KEY`: site key publik reCAPTCHA v3.

Kedua nilai tersebut adalah konfigurasi publik yang masuk ke bundle browser,
bukan secret. API secret Cloudinary, private key, dan credential server tidak
boleh ditambahkan sebagai `--dart-define` aplikasi web.

## Pipeline

Pull request ke `main` menjalankan dependency install, analyzer, seluruh test,
Firestore Rules emulator test, dan build web. Pull request tidak melakukan
deployment. Push atau merge ke `main` menjalankan quality gate yang sama lalu
mengunggah `build/web` ke GitHub Pages.

Base href produksi harus tetap `/cermatify/` selama URL Pages berbentuk
`https://yuelearningcode.github.io/cermatify/`. Routing menggunakan hash URL,
sehingga refresh dan direct URL tidak membutuhkan rewrite server.

## Smoke test setelah deployment

1. Buka landing page pada private/incognito window.
2. Pastikan manifest, favicon, dan service worker tidak gagal di DevTools.
3. Buka route publik `#/login` dan `#/register`.
4. Pastikan route acak menampilkan halaman "Halaman tidak ditemukan".
5. Tanpa login, buka `#/profile` dan `#/admin-dashboard`; keduanya harus menuju login.
6. Setelah Firebase tersedia, uji customer, mentor, dan admin sesuai checklist
   penerimaan pada `TODO_WEB.md`.

## Rollback

1. Buka tab **Actions** dan pilih deployment terakhir yang diketahui stabil.
2. Pilih **Re-run all jobs** untuk menerbitkan ulang artifact dari commit stabil.
3. Jika commit terbaru harus dibatalkan, buat `git revert <commit>` pada branch
   baru, review melalui pull request, lalu merge ke `main`.
4. Jangan memakai force-push atau menghapus riwayat branch produksi.
5. Setelah rollback, ulangi smoke test dan pastikan cache/service worker mengambil
   versi stabil.

## Staging

Environment staging belum diperlukan untuk rilis awal. Tambahkan staging ketika
custom domain, backend terpisah, atau proses persetujuan manual sudah tersedia.
