# Elyramart

Elyramart Flutter marketplace starter for Android.

## Current scope
- English/Bangla language toggle
- Home/category preview
- Orders and home-services preview
- Settings screen
- GitHub Actions workflow to generate the Android project and build a release APK

## Important: not production-ready yet
This is a UI/build starter only. Customer and seller authentication, Firestore products/orders, seller approval, admin dashboard/role permissions, payments, delivery workflow, privacy policy, and Play Store compliance are not implemented. Do not publish this preview as a live marketplace.

## Build
Push to `main` or run **Build Elyramart Android APK** from the Actions tab. Download the `elyramart-release-apk` artifact when the workflow succeeds.

## Firebase
Firebase project: `elyramart` (project number `275927108805`). Add the Android app with package `com.elyramartbd.elyramart`, download its `google-services.json`, and configure Firebase before enabling production sign-in and database features. Never commit private service-account keys.
