# Quality Gate

Quality gate lokal dan CI Cermatify adalah:

- `flutter analyze` harus selesai dengan **No issues found**.
- Seluruh `flutter test` harus lulus.
- Firestore Rules emulator test harus lulus.
- Build web release dan Wasm dry run harus berhasil.
- Manifest PWA harus berupa JSON valid dan service worker/icon wajib tersedia.
- Bundle web tidak boleh mengandung API secret Cloudinary atau private key.

Log aplikasi menggunakan logger debug terpusat dan tidak mencetak data melalui
`print` pada release build. Integration test autentikasi, upload, dan smoke test setiap role dijalankan
setelah Firebase serta environment eksternal tersedia kembali.
