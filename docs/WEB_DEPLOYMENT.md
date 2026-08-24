# Deployment Flutter Web Cermatify

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
