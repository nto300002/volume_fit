const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();

exports.deleteAccount = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }

  const userDocument = admin.firestore().collection('users').doc(uid);
  try {
    await admin.firestore().recursiveDelete(userDocument);
    await admin.auth().deleteUser(uid);
    return { deleted: true };
  } catch (error) {
    console.error('Account deletion failed.', error);
    throw new HttpsError('internal', 'Account deletion failed.');
  }
});
