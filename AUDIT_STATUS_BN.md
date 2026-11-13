# Elyramart — কাজের অগ্রগতি ও রিলিজ অডিট
সর্বশেষ আপডেট: 2026-11-13

## এই ধাপে সম্পন্ন
- `lib/firebase_options.dart` যোগ করা হয়েছে; প্রদত্ত Elyramart Firebase Android project ID, app ID ও storage bucket ব্যবহার করা হয়েছে।
- `lib/screens/account_page.dart` যোগ: Email/password customer registration, sign-in এবং sign-out।
- `lib/screens/catalog_page.dart` যোগ: Firestore থেকে active product list এবং product detail preview।
- `lib/screens/service_request_page.dart` যোগ: signed-in customer-এর technician/home-service request submission।
- Android workflow নিরাপদ করা হয়েছে: root source overwrite না করে temporary Flutter Android host project তৈরি করে; Flutter analyze/test, APK এবং AAB build চালায়।
- Storage rules সংশোধন: শুধু approved seller নিজের product image path-এ JPG/PNG/WEBP 5 MB-এর কম ছবি upload করতে পারবে; admin-ও পারবে।
- v0.21 source package-এর Firebase Functions syntax checks ও 5টি validation test স্থানীয়ভাবে চালানো হয়েছে: 5 passed, 0 failed।

## এখনো সম্পন্ন নয় / বাহ্যিক অনুমতি প্রয়োজন
1. GitHub Actions-এর Flutter analyze/test এবং Android APK/AAB build সফল হয়েছে কি না—run result পাওয়া/যাচাই করা বাকি।
2. Firebase Console-এ Email/Phone Authentication provider enable, Firestore ও Storage initialize করা বাকি।
3. Firestore rules, Storage rules, indexes ও Cloud Functions owner-এর Firebase project-এ deploy করা বাকি।
4. Owner-এর Firebase Auth UID দিয়ে trusted environment-এ Admin custom claim bootstrap করা বাকি; Admin secret বা service-account key chat/GitHub-এ দেওয়া যাবে না।
5. Seller application/approval, product create/update, cart, server-validated checkout, order status এবং admin panel সম্পূর্ণ end-to-end test বাকি।
6. Android release signing keystore এবং Play Console upload key setup বাকি; debug-signed AAB Play Store-এ জমা দেওয়া যাবে না।
7. Privacy policy URL, Data safety, content rating, target audience, app access instructions এবং Play Console Closed Testing সম্পন্ন করা বাকি।
8. বাস্তব Android ফোনে login, network error, order ও service request পরীক্ষা বাকি।

## সীমাবদ্ধতা
- এই পরিবেশে Flutter/Dart SDK নেই; তাই Flutter compile/analyze/test বা APK/AAB তৈরি হয়েছে বলে দাবি করা হচ্ছে না।
- Firebase project-এ সরাসরি deploy করার অনুমতি/সংযোগ এই কাজের পরিবেশে নেই।
- Firebase client config app initialization-এর জন্য ব্যবহৃত; Admin service-account JSON, passwords, signing keystore এবং private keys কখনো repository-তে commit করা যাবে না।
