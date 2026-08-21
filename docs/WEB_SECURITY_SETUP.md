# Web Security Setup

## Immediate external actions

The Cloudinary API secret that used to be embedded in the Flutter source must
be rotated in the Cloudinary dashboard. Removing it from the current source
does not invalidate copies in Git history or previously built applications.

1. Rotate the exposed Cloudinary API secret.
2. Create a dedicated unsigned upload preset for Cermatify.
3. Restrict the preset to images, the smallest practical maximum file size,
   controlled transformations, and a dedicated asset folder.
4. Disable overwrite and unauthenticated destructive operations.

Do not put the new API secret in Flutter, `.env`, GitHub Actions build
arguments, or `--dart-define`. Browser bundles are public.

## Local run

The Cloudinary cloud name is public and currently has a non-secret default.
Provide the restricted preset when running the app:

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
