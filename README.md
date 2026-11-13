# Elyramart

Flutter marketplace starter for Android, using Firebase.

## Implemented
- English/Bangla interface toggle
- Firebase Android initialization using the owner's Android app configuration
- Customer email/password registration, sign-in, password reset and email verification email
- Seller application submission and admin approval workflow
- Admin dashboard protected by Firebase custom claim `admin: true`
- Product creation with optional seller product-photo upload to Firebase Storage and image display in the catalogue
- Persistent shopping cart (saved on device) and cash-on-delivery checkout with phone and delivery address
- Home-service request submission and admin request status workflow
- Category-specific product browsing from the home screen
- Customer order history and admin order status updates
- Initial Firestore and Storage security rules
- GitHub Actions Android release APK build and optional Play Store AAB build when private signing secrets are configured

## Firebase project
- Project ID: `elyramart`
- Project number: `275927108805`
- Android package: `com.elyramartbd.elyramart`

## Owner setup required
1. In Firebase Console, enable Authentication > Email/Password.
2. Create the Cloud Firestore database.
3. Publish `firestore.rules` under Firestore > Rules.
4. Enable Firebase Storage and publish `storage.rules`.
5. From a trusted computer with Firebase CLI installed, run `firebase deploy --only firestore:rules,firestore:indexes,storage,functions` from the repository root. The `placeOrder` callable function validates current product prices and stock and creates orders transactionally.
6. Enable billing for Firebase Cloud Functions if the project requires it, and confirm the function deploys in `asia-south1`.
7. Create the owner's account through the app. Copy its Firebase Authentication UID.
8. Follow [Owner Admin Setup](docs/OWNER_ADMIN_SETUP.md) to set the secure custom claim using Firebase Admin SDK. Run `npm install firebase-admin` from the local repository root first. Never commit the service-account JSON.
9. To run on Web or iOS, register those Firebase apps and add their exact platform options; currently only Android is configured.

## Build APK and Play Store AAB
Open GitHub Actions > **Build Elyramart Android APK and Play Store AAB**. The workflow runs on each push to `main`. After a successful run, download the `Elyramart-Android-APK` artifact.

A signed Play Store AAB is produced only after the owner configures these repository Actions secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, and `ANDROID_KEY_PASSWORD`. Never put the keystore or passwords in the repository.

## Important launch gaps
This is not yet ready for public production or Play Store release. Payment gateway integration, delivery partner workflow, push notifications, complete Bangla translation across all screens, privacy policy/terms owner review, medicine-sale legal compliance, full QA, app signing key management, Play Console declarations and closed testing are still required. Cash on delivery is the only implemented payment option. Firestore/Storage rules and the trusted checkout Cloud Function must be deployed and tested in the owner's Firebase project before launch. The release workflow can build an APK; signed AAB generation remains gated on private upload-keystore secrets.
