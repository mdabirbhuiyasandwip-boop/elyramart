# Elyramart

Flutter marketplace starter for Android, using Firebase.

## Implemented
- English/Bangla interface toggle
- Firebase Android initialization using the owner's Android app configuration
- Customer email/password registration and sign-in
- Seller application submission and admin approval workflow
- Admin dashboard protected by Firebase custom claim `admin: true`
- Product creation and product catalogue
- Cart and cash-on-delivery order placement
- Customer order history and admin order status updates
- Initial Firestore and Storage security rules
- GitHub Actions Android release APK build

## Firebase project
- Project ID: `elyramart`
- Project number: `275927108805`
- Android package: `com.elyramartbd.elyramart`

## Owner setup required
1. In Firebase Console, enable Authentication > Email/Password.
2. Create the Cloud Firestore database.
3. Publish `firestore.rules` under Firestore > Rules.
4. Enable Firebase Storage and publish `storage.rules`.
5. Create the owner's account through the app. Copy its Firebase Authentication UID.
6. Follow [Owner Admin Setup](docs/OWNER_ADMIN_SETUP.md) to set the secure custom claim using Firebase Admin SDK. Never commit the service-account JSON.
7. To run on Web or iOS, register those Firebase apps and add their exact platform options; currently only Android is configured.

## Build APK
Open GitHub Actions > **Build Elyramart Android APK**. The workflow runs on each push to `main`; download the `elyramart-release-apk` artifact after a successful run.

## Important launch gaps
This is not yet ready for public production or Play Store release. Payment gateway integration, server-side stock reservation and order validation, delivery partner workflow, push notifications, seller product dashboard, account recovery/email verification, privacy policy/terms, medicine-sale legal compliance, full QA, app signing key management, Play Console declarations and closed testing are still required. Cash on delivery is the only implemented payment option. Cart is currently in-memory and resets when the app restarts. Firestore/Storage rules must be reviewed and tested before launch.
