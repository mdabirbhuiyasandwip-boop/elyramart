import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication and profile operations for customers and sellers.
/// Admin access is intentionally controlled by server-set custom claims,
/// never by a role value supplied from the client.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authChanges() => _auth.authStateChanges();

  Future<UserCredential> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  Future<void> submitSellerApplication({
    required String shopName,
    required String phone,
    required String address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    await _db.collection('sellerApplications').doc(user.uid).set({
      'uid': user.uid,
      'shopName': shopName.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<Map<String, dynamic>?> loadMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snapshot = await _db.collection('users').doc(user.uid).get();
    return snapshot.data();
  }
}
