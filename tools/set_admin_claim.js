// Run locally from a trusted machine after installing firebase-admin.
// Keep the service-account JSON outside this repository.
const admin = require('firebase-admin');

async function main() {
  const uid = process.argv[2];
  if (!uid) {
    throw new Error('Usage: GOOGLE_APPLICATION_CREDENTIALS=/secure/service-account.json node set_admin_claim.js FIREBASE_AUTH_UID');
  }

  admin.initializeApp({ credential: admin.credential.applicationDefault() });

  // Preserve any existing custom claims (for example, future support claims).
  const user = await admin.auth().getUser(uid);
  const existingClaims = user.customClaims || {};
  await admin.auth().setCustomUserClaims(uid, { ...existingClaims, admin: true });

  console.log('Admin claim set without removing existing claims.');
  console.log('Ask the owner to sign out and sign in again to refresh the ID token.');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
