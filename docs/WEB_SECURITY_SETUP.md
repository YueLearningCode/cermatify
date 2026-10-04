# Web Security Setup

## Immediate external actions

The Cloudinary API secret that used to be embedded in the Flutter source must
be rotated in the Cloudinary dashboard. Removing it from the current source
does not invalidate copies in Git history or previously built applications.

1. Rotate the exposed Cloudinary API secret.
2. Create a dedicated unsigned upload preset for Cermatify.
3. Restrict the preset to image formats, controlled transformations, and a
   dedicated asset folder. Validate file size in the upload client; upload
   presets do not support a per-preset file size limit.
4. Disable overwrite and unauthenticated destructive operations.

Do not put the new API secret in Flutter, `.env`, GitHub Actions build
arguments, or `--dart-define`. Browser bundles are public.

## Local run

### Membuat preset untuk upload foto

Default aplikasi sekarang memakai cloud `rgovyuw1` dan preset `flutter_upload`,
sesuai environment Cloudinary yang dikonfirmasi melalui screenshot. Kedua nilai
ini bersifat publik. Preset tersebut sudah tersedia; langkah pembuatan berikut
hanya diperlukan saat menyiapkan environment baru.

Jika muncul `CLOUDINARY_UPLOAD_PRESET belum dikonfigurasi`, aplikasi belum
menerima nama preset saat dijalankan. Menambahkan flag saja belum cukup bila
preset tersebut belum dibuat pada akun Cloudinary.

1. Buka Cloudinary Console untuk cloud `rgovyuw1` (cloud name default proyek).
2. Buka Settings > Upload > Upload presets, lalu tambahkan preset.
3. Isi nama `flutter_upload` dan pilih signing mode **Unsigned**.
4. Batasi allowed formats ke `jpg`, `jpeg`, `png`, dan `webp`, serta gunakan
   folder asset khusus aplikasi. Batas ukuran file perlu divalidasi di client,
   bukan melalui upload preset.
5. Simpan preset sebelum menjalankan ulang aplikasi.

Untuk VS Code, pilih konfigurasi **Cermatify (Cloudinary)** di Run and Debug.
Konfigurasi tersedia baik saat membuka folder workspace induk maupun folder
Flutter `cermatify`. Konfigurasi ini mengirim nama preset lewat `toolArgs`.
Jika nama preset berbeda, ubah nilai `CLOUDINARY_UPLOAD_PRESET` pada `launch.json`.

Untuk Android Studio, buka Run > Edit Configurations > konfigurasi Flutter,
lalu isi Additional run args dengan:

```text
--dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Hentikan sesi run sebelumnya dan jalankan kembali. Nilai `String.fromEnvironment`
dibaca saat kompilasi; hot reload tidak mengganti konfigurasi build.

Konfigurasi IDE tidak membuat preset di Cloudinary. Keberhasilan upload nyata
baru dapat diverifikasi setelah preset tersimpan dan aplikasi dijalankan ulang.

### Upload ditolak dengan HTTP 400

Service upload membaca alasan penolakan dari JSON `error.message` atau header
`X-Cld-Error` dan menampilkannya sebagai `Upload ditolak Cloudinary: ...`.
Alasan yang sama dicatat melalui `AppLogger` saat debug. Status HTTP 400 saja
tidak cukup untuk menentukan apakah masalah berada pada preset, cloud, atau file.

Pastikan nilai **Cloud name** di Cloudinary sesuai dengan cloud tujuan upload.
Jangan menyalin **Product Environment ID** sebagai penggantinya. Bila cloud name
berbeda dari default proyek, jalankan dengan kedua flag berikut:

```text
--dart-define=CLOUDINARY_CLOUD_NAME=<cloud-name-aktual>
--dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Periksa respons penolakan saat mencoba upload kembali. Tidak ada API secret yang
dibutuhkan untuk request unsigned. Rules lokal untuk bukti pembayaran menerima
cloud `rgovyuw1` dan cloud lama `dvxsmpz3m`. Perubahan rules ini belum dideploy;
penyimpanan order dengan URL cloud baru membutuhkan rules yang sudah diperbarui.

The Cloudinary cloud name and unsigned preset have public project defaults.
You can explicitly supply the preset when running the app:

Windows PowerShell, jalankan dari root project Flutter:

```powershell
flutter run -d chrome --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Bila ingin memecah perintah menjadi beberapa baris di PowerShell, gunakan
backtick, bukan backslash:

```powershell
flutter run -d chrome `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Bash/Linux/macOS:

```bash
flutter run -d chrome \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_restricted_unsigned_preset
```

## Production build

Windows PowerShell:

```powershell
flutter build web --release --base-href /cermatify/ --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Bash/Linux/macOS:

```bash
flutter build web --release \
  --base-href /cermatify/ \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=flutter_upload
```

Store the preset name as a GitHub Actions repository variable, not as a
secret. Security must come from the preset restrictions because values passed
to a Flutter Web build can be extracted from the bundle.

## Firestore Rules warning

`firestore.rules` deliberately prevents normal users from changing `saldo`.
The current respondent reward flow and admin settlement flow mutate balances
from client code. Move those operations to a callable Cloud Function or
backend transaction before deploying the rules to production.

Recommended trusted operations:

- Enroll a respondent and award the balance atomically.
- Approve an order and credit a mentor atomically and idempotently.
- Approve/reject a withdrawal and debit/refund the balance atomically.
- Validate service prices on the server instead of trusting client values.

Automated rule tests cover role escalation, protected balances, trusted service
prices, questionnaire rewards, and chat membership. Run them with:

```bash
npm --prefix firebase-tests ci
npx --yes firebase-tools@15.28.1 emulators:exec \
  --only firestore \
  --project demo-cermatify \
  "npm --prefix firebase-tests test"
```

Deploy only after the role and transaction tests pass:

```bash
firebase deploy --only firestore:rules
```
