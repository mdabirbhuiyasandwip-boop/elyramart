'use strict';

const admin = require('firebase-admin');

async function main() {
  const uid = process.argv[2];
  if (!uid || !/^[A-Za-z0-9_-]{10,128}$/.test(uid)) {
    throw new Error('Usage: node tools/set_admin_claim.js FIREBASE_AUTH_UID');
  }

  if (!admin.apps.length) {
    admin.initializeApp({credential: admin.credential.applicationDefault()});
  }

  const auth = admin.auth();
  const user = await auth.getUser(uid);
  const existingClaims = user.customClaims || {};
  await auth.setCustomUserClaims(uid, {...existingClaims, admin: true});

  console.log('Admin claim enabled for Firebase Auth UID:', uid);
  console.log('Ask the owner to sign out and sign in again to refresh the ID token.');
}

main().catch((error) => {
  console.error('Could not grant owner admin access:', error.message);
  process.exitCode = 1;
});
