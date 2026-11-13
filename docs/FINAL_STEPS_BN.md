# Elyramart — চূড়ান্ত সেটআপ গাইড (বাংলা)
সর্বশেষ হালনাগাদ: ১৩ নভেম্বর ২০২৬

এই গাইডে কোডে করা কাজ এবং মালিকের Firebase / Google Play অ্যাকাউন্টে করতে হবে এমন কাজ আলাদা করা হয়েছে। কোনো গোপন কী, পাসওয়ার্ড বা service-account JSON চ্যাটে পাঠাবেন না।

## ১. কোডে প্রস্তুত
- Android Flutter app, Firebase Android initialization এবং English/Bangla home navigation।
- Customer email/password registration, sign-in, password reset ও email verification।
- Seller application, Admin approval এবং seller dashboard।
- Product catalog, persistent cart, Cash-on-Delivery order।
- `placeOrder` Cloud Function: সার্ভার থেকে active product, বর্তমান price ও stock যাচাই করে transaction-এ stock কমায় এবং order তৈরি করে।
- Admin dashboard: seller application, product status, service request ও order status পরিচালনা।
- Firestore/Storage rules, Firebase deployment config, Node checkout validation tests।
- Android APK CI workflow; private upload keystore secrets থাকলে signed Play Store AAB build।
- Owner Admin custom-claim bootstrap script এবং privacy/terms draft।

## ২. Firebase Console-এ মালিকের কাজ
1. Firebase Console-এ `elyramart` project খুলুন।
2. Authentication → Sign-in method → Email/Password চালু করুন।
3. Firestore Database তৈরি করুন। নতুন database হলে `asia-south1` region বিবেচনা করুন; database তৈরি হয়ে গেলে location বদলানো যায় না।
4. Storage চালু করুন।
5. Cloud Functions deploy করতে Firebase project-এ প্রয়োজনীয় billing/Blaze plan চালু থাকতে পারে।
6. Trusted Firebase CLI বা সংযুক্ত Firebase integration দিয়ে repository root থেকে চালান:
   `firebase deploy --only firestore:rules,firestore:indexes,storage,functions`
7. Deploy শেষে Functions-এ `placeOrder` নামের callable function `asia-south1` region-এ আছে কি না দেখুন।

## ৩. Owner Admin access
1. Elyramart অ্যাপে নিজের owner email দিয়ে customer account তৈরি করুন।
2. Firebase Console → Authentication → Users থেকে নিজের UID কপি করুন।
3. Trusted computer-এ repository clone করে root folder-এ `npm install firebase-admin` চালান।
4. Firebase service-account JSON নিরাপদে repository-র বাইরে রাখুন এবং `GOOGLE_APPLICATION_CREDENTIALS` environment variable-এ তার absolute path দিন।
5. repository root থেকে চালান:
   `node tools/set_admin_claim.js YOUR_FIREBASE_AUTH_UID`
6. অ্যাপ থেকে sign out করে আবার sign in করুন। এরপর Account থেকে Admin dashboard দেখা উচিত।

Service-account JSON, passwords, Android keystore বা private keys কখনো GitHub-এ commit করবেন না।

## ৪. APK build
1. GitHub repository → Actions খুলুন।
2. `Build Elyramart Android APK and Play Store AAB` workflow নির্বাচন করুন।
3. সর্বশেষ run শেষ হওয়া পর্যন্ত অপেক্ষা করুন।
4. সফল হলে `Elyramart-Android-APK` artifact ডাউনলোড করুন।
5. APK নিজের Android ফোনে install করে registration, sign-in, product browse, cart, COD order, seller application ও service request পরীক্ষা করুন।

## ৫. Play Store AAB
Play Store upload-এর আগে owner-কে upload keystore তৈরি করে GitHub repository → Settings → Secrets and variables → Actions-এ এই চারটি secret যোগ করতে হবে:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`

Secrets সেট না থাকলে workflow APK তৈরি করতে পারে, কিন্তু Play Store AAB ধাপ skip করবে। Keystore হারালে ভবিষ্যৎ update জটিল হতে পারে—নিরাপদ backup রাখুন।

## ৬. Public launch-এর আগে বাধ্যতামূলক যাচাই
- Delivery fee, delivery zones, delivery partner assignment এবং order fulfilment policy এখনো নির্ধারিত/বাস্তবায়িত নয়।
- Online payment gateway নেই; বর্তমানে শুধু Cash on Delivery।
- Product image upload UI সম্পূর্ণ নয়।
- Push notification নেই।
- বাংলা অনুবাদ সব sub-screen-এ সম্পূর্ণ নয়।
- Privacy Policy ও Terms draft—মালিকের প্রকৃত business/legal details দিয়ে review করে public URL-এ publish করতে হবে।
- Medicine listing/delivery কেবল সংশ্লিষ্ট Bangladesh legal licensing, prescription এবং pharmacy partner compliance নিশ্চিত হলে চালু করা যাবে।
- Google Play Data safety, content rating, target audience, app access instructions, signing এবং closed testing সম্পন্ন করতে হবে।

## ৭. Release readiness
APK artifact সফলভাবে তৈরি, Firebase deployment, বাস্তব Firebase integration test, owner Admin claim, signing AAB এবং Play Console testing—সবগুলো সফল না হওয়া পর্যন্ত অ্যাপকে Play Store-ready বলা যাবে না।
