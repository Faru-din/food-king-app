import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Check initial auth state but only after flutterfire configure is done.
    // _auth.authStateChanges().listen((User? user) {
    //   _user = user;
    //   if (user != null) _fetchUserData(user.uid);
    //   notifyListeners();
    // });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCred = await _auth.signInWithCredential(credential);
      
      if (userCred.user != null) {
        // Save user to firestore if new
        await _saveUserToFirestore(userCred.user!, userCred.user!.displayName ?? '');
      }
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signInWithPhone(String phoneNumber, Function(String) codeSentCallback) async {
    _setLoading(true);
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _setLoading(false);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.message);
        _setLoading(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSentCallback(verificationId);
        _setLoading(false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    _setLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCred = await _auth.signInWithCredential(credential);
      if (userCred.user != null) {
        await _saveUserToFirestore(userCred.user!, 'User');
      }
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> _saveUserToFirestore(User user, String name) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      UserModel newUser = UserModel(
        id: user.uid,
        name: name,
        phoneNumber: user.phoneNumber ?? '',
        email: user.email,
      );
      await docRef.set(newUser.toMap());
      _userModel = newUser;
    } else {
      _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
  }
}
