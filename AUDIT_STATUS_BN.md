# Elyramart repository audit — 2026-11-13

## Findings
- The current `main` branch contains a Flutter entry point at `lib/main.dart`, but it imports `firebase_options.dart` and `screens/account_page.dart`, `screens/catalog_page.dart`, and `screens/service_request_page.dart`. These paths were not found in the repository during this audit.
- `pubspec.yaml` is present, but the repository is not yet a complete, self-consistent Flutter source tree; a successful Android build cannot be assumed.
- `firestore.rules`, `storage.rules`, and `.github/workflows/build-apk.yml` are present.
- A newer v0.21 source archive exists separately and includes `lib/backend/marketplace_service.dart`, Firebase Functions, security rules, and an APK/AAB workflow. It has not yet been synchronized into this repository.
- Backend validation tests from the v0.21 source archive were run locally: 5 passed, 0 failed.
- Flutter/Dart SDK was unavailable in the audit environment; no Flutter compile or Android APK/AAB build is claimed.

## Required next actions
1. Synchronize one complete, matching source version into the repository (do not mix files from older and newer versions).
2. Confirm the Android Firebase configuration is correctly associated with package `com.elyramartbd.elyramart`; do not commit service-account credentials or signing keys.
3. Deploy and test Firestore/Storage rules and Firebase Functions in the owner's Firebase project.
4. Run Flutter analyze, widget tests, and Android APK/AAB build using GitHub Actions.
5. Test customer, seller, admin, product image upload, checkout, order status, and technician/home-service flows on a physical Android device.
6. Complete privacy policy, terms, Play Console declarations, signing, and closed testing before public release.

## Security
Never commit Firebase Admin service-account JSON, Play signing keystore, passwords, or private API credentials. Firebase client configuration is not an Admin credential, but repository visibility and Firebase API restrictions should still be reviewed.
