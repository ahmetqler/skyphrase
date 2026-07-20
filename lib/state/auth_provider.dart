import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/user_repository.dart';
import '../l10n/strings.dart';

/// Firebase Authentication durumunu uygulamaya bağlar: giriş/kayıt/çıkış,
/// e-posta doğrulama ve hata mesajlarının kullanıcı dostu hale getirilmesi.
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  late final StreamSubscription<User?> _authSub;

  User? _user;
  bool _initialized = false;

  AuthProvider() {
    _authSub = _auth.userChanges().listen((u) {
      _user = u;
      _initialized = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get initialized => _initialized;
  bool get isLoggedIn => _user != null;
  bool get isVerified => _user?.emailVerified ?? false;
  String? get uid => _user?.uid;
  String? get email => _user?.email;

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  /// Kullanıcı adı + e-posta + şifre ile hesap açar, doğrulama e-postası
  /// gönderir. Başarılıysa null, hataysa kullanıcıya gösterilecek mesajı
  /// döner.
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.length < 3) {
      return Strings.errUsernameTooShort;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmedUsername)) {
      return Strings.errUsernameFormat;
    }

    if (!await _userRepository.isUsernameAvailable(trimmedUsername)) {
      return Strings.errUsernameTaken;
    }

    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    }

    try {
      await _userRepository.claimUsernameAndCreateProfile(
        uid: cred.user!.uid,
        username: trimmedUsername,
        email: email.trim(),
      );
    } on UsernameTakenException {
      // Nadiren iki kişi aynı anda aynı adı almaya çalışırsa: hesabı geri al.
      await cred.user!.delete();
      return Strings.errUsernameTakenRace;
    }

    await cred.user!.sendEmailVerification();
    return null;
  }

  /// E-posta ya da kullanıcı adıyla giriş yapar.
  Future<String?> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    var email = emailOrUsername.trim();
    if (!email.contains('@')) {
      final resolved = await _userRepository.emailForUsername(email);
      if (resolved == null) {
        return Strings.errUsernameNotFound;
      }
      email = resolved;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Kullanıcı e-postasını onayladıktan sonra "Onayladım" butonuna basınca
  /// çağrılır: sunucudan güncel doğrulama durumunu çeker.
  Future<void> refreshVerificationStatus() async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Strings.errEmailInUse;
      case 'invalid-email':
        return Strings.errInvalidEmail;
      case 'weak-password':
        return Strings.errWeakPassword;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Strings.errWrongCredentials;
      case 'too-many-requests':
        return Strings.errTooManyRequests;
      default:
        return Strings.errGeneric(e.code);
    }
  }
}
