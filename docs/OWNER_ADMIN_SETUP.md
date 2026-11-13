# Secure owner admin setup

1. Create the owner account once through the app's customer registration screen.
2. In Firebase Console > Authentication > Users, copy the owner's UID.
3. On a trusted computer, install Node.js. In a local clone of this repository, run `npm install firebase-admin` from the repository root. The installed package is ignored by Git and must not be committed.
4. Download a Firebase service-account JSON from Project settings > Service accounts. Store it OUTSIDE this Git repository and never share or commit it. Set `GOOGLE_APPLICATION_CREDENTIALS` to its absolute file path.
5. Run the repository script with:
   `GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/service-account.json node tools/set_admin_claim.js OWNER_UID`
6. Sign out and sign back in inside Elyramart so the refreshed ID token includes the admin claim.

The app does not let a user promote themselves. Admin permission is a Firebase custom claim set using the Admin SDK only.
