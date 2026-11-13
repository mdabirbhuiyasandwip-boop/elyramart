// Run locally from a trusted machine after installing firebase-admin.
// Keep the service-account JSON outside this repository.
const admin = require('firebase-admin');
const uid = process.argv[2];
if (!uid) {
  console.error('Usage: GOOGLE_APPLICATION_CREDENTIALS=/secure/service-account.json node set_admin_claim.js FIREBASE_AUTH_UID');
  process.exit(1);
}
admin.initializeApp({ credential: admin.credential.applicationDefault() });
admin.auth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log('Admin claim set. Ask the user to sign out and sign in again.');
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
