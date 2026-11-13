# Elyramart

Elyramart Flutter marketplace starter for Android and Web.

## Implemented in this repository
- English/Bangla language toggle and marketplace preview screens
- Firebase Core initialization for Android and Web
- Firebase Authentication + Firestore service layer for customer registration/sign-in
- Seller application submission (pending approval)
- Initial Firestore and Storage security rules
- GitHub Actions workflow to build a release Android APK

## Firebase project
- Project ID: `elyramart`
- Project number: `275927108805`
- Android application ID: `com.elyramartbd.elyramart`

The Firebase client options are in `lib/firebase_options.dart`. These are client configuration values, not admin credentials. Never commit service-account private keys.

## Required Firebase Console actions
1. Enable **Email/Password** in Authentication > Sign-in method.
2. Create the Cloud Firestore database.
3. Publish the repository's `firestore.rules` in Firestore > Rules.
4. Publish `storage.rules` in Storage > Rules after enabling Storage.
5. For secure owner/admin access, configure a trusted server (Cloud Functions/Admin SDK) to set the Firebase custom claim `admin: true` on the owner's UID. Never let the mobile app assign its own admin role.
6. Add Android app package `com.elyramartbd.elyramart` in Firebase project settings and verify its app ID matches the configured Android app ID.

## Not production-ready yet
The current UI is a starter preview. Login/register screens are not yet connected to the service layer; product management, cart/checkout, full order lifecycle, seller dashboard/approval UI, owner admin dashboard, payment gateway, push notifications, and privacy/terms pages still need implementation and testing. The security rules are starter rules and must be reviewed before launch. Do not publish this preview as a live marketplace.

## Build APK
Push to `main` or open **Actions > Build Elyramart Android APK** and run the workflow. When successful, open the workflow run and download the `elyramart-release-apk` artifact.
