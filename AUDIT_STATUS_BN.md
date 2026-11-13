# Elyramart — কাজের অগ্রগতি ও রিলিজ অডিট
সর্বশেষ আপডেট: 2026-11-13

## GitHub-এ যাচাই করা বর্তমান ফিচার
- Flutter Android app entry point এবং Firebase Android options আছে।
- Customer registration/sign-in, email verification reminder, password reset ও profile load service আছে।
- Seller application, seller approval এবং seller dashboard আছে।
- Product catalog, local persistent cart, Cash-on-Delivery order placement আছে।
- Owner admin custom-claim gate, seller/product moderation, service request ও order status management screen আছে।
- Customer home-service / technician request form আছে।
- App home screen-এ বাংলা/English switch আছে; তবে সব sub-screen-এর অনুবাদ সম্পূর্ণ নয়।

## এই ধাপে সম্পন্ন repository পরিবর্তন
- Android GitHub Actions workflow নিরাপদ করা হয়েছে: Flutter Android host project temporary folder-এ generate হয়; repository root-এর application source overwrite করে না।
- Workflow-তে Flutter package resolution, analyze, tests, release APK build এবং upload যুক্ত আছে।
- Play Store AAB build কেবল private release keystore secrets থাকলে চলবে; debug-signed AAB-কে Play Store-ready হিসেবে দেখানো হবে না।
- Firebase deployment config `firebase.json` এবং empty composite index file `firestore.indexes.json` যোগ করা হয়েছে।
- Storage rules সংশোধন: approved seller নিজের product-image path-এ JPG/PNG/WEBP 5 MB-এর কম ছবি upload করতে পারবে; admin-ও পারবে।
- Repository-তে বাংলা audit report, owner final setup guide এবং secure Admin custom-claim bootstrap script যোগ/হালনাগাদ করা হয়েছে।

## বাস্তব পরীক্ষা ও যা এখনো নিশ্চিত নয়
- v0.21 source package-এর আগের validation test 5/5 সফল হয়েছিল। এই repository-র trusted checkout input validation test 3/3 সফল হয়েছে। Cloud Function deploy বা live Firebase test এখনো হয়নি।
- এই পরিবেশে Flutter/Dart SDK নেই; Flutter analyze/test এবং Android APK/AAB build-এর সফল ফল এখনো পাওয়া যায়নি।
- GitHub Actions commit status-এ এখনো কোনো completed check দেখা যায়নি।
- Firebase rules/Firestore/Auth/Storage live project-এ deploy বা end-to-end পরীক্ষা করা হয়নি।
- Checkout এখন callable Cloud Function ব্যবহার করে; server-side function current active product, price, stock ও quantity transaction-এ যাচাই করে stock কমায় এবং order তৈরি করে। Firestore client-side order creation বন্ধ করা হয়েছে। Function validation tests 3/3 সফল; তবে Firebase project-এ deploy ও live concurrency test বাকি।

## অবশিষ্ট কাজ
1. GitHub Actions-এ Flutter analyze/test এবং Android APK build সফল করা; error হলে ঠিক করা।
2. Firebase Console-এ Email/Password Auth enable, Firestore ও Storage initialize করা।
3. Owner-এর অনুমতিতে Firestore/Storage rules deploy ও বাস্তব customer/seller/admin access পরীক্ষা করা।
4. Owner-এর Firebase Auth UID দিয়ে trusted environment-এ `tools/set_admin_claim.js` ব্যবহার করে Admin custom claim bootstrap করা।
5. Callable checkout Cloud Function deploy করে real Firebase project-এ order total, price, stock decrement এবং concurrent order behaviour পরীক্ষা করা।
6. Product image upload UI, seller inventory update, seller order fulfilment ও customer order tracking পরীক্ষা/সম্পূর্ণ করা।
7. বাংলা/English অনুবাদ account, seller, admin, cart ও service screens-এ সম্পূর্ণ করা।
8. Private Android upload keystore তৈরি করে GitHub Actions Secrets-এ `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD` সেট করা।
9. Privacy policy URL, Data safety, content rating, target audience, app access instructions এবং Play Console Closed Testing সম্পন্ন করা।
10. বাস্তব Android ফোনে login, product browsing, cart, checkout, seller approval, admin controls ও technician request পরীক্ষা করা।

## নিরাপত্তা
- Firebase Admin service-account JSON, passwords, Android signing keystore এবং private keys chat বা repository-তে পাঠাবেন/commit করবেন না।
- Firebase client API key app configuration-এর অংশ; এটি Admin credential নয়। Firebase API restrictions ও authorized domains/Android app settings তবু পর্যালোচনা করতে হবে।
