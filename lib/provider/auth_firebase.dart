import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isLoggedIn => user != null;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

final authServiceProvider = NotifierProvider<AuthFirebase, AuthState>(() {
  return AuthFirebase();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthFirebase extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    return AuthState(user: _auth.currentUser);
  }

  Future<void> _updateState({
    AuthStatus? status,
    String? errorMessage,
  }) async {
    final currentUser = _auth.currentUser;
    state = AuthState(
      status: status ?? state.status,
      errorMessage: errorMessage,
      user: currentUser,
    );
  }

  // Fungsi login biasa
  Future<void> login(String email, String password) async {
    if (state.isLoading) return;

    try {
      await _updateState(status: AuthStatus.loading, errorMessage: null);

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _updateState(status: AuthStatus.success);
    } catch (e) {
      await _updateState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  // Fungsi register
  Future<void> register(String email, String password) async {
    if (state.isLoading) return;

    try {
      await _updateState(status: AuthStatus.loading, errorMessage: null);

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _updateState(status: AuthStatus.success);
    } catch (e) {
      await _updateState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  // Google Login
  Future<void> loginWithGoogle() async {
    if (state.isLoading) return;

    try {
      await _updateState(status: AuthStatus.loading, errorMessage: null);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        await _updateState(status: AuthStatus.idle);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      await _updateState(status: AuthStatus.success);
    } catch (e) {
      await _updateState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  // Apple Login
  Future<void> loginWithApple() async {
    if (state.isLoading) return;

    try {
      await _updateState(status: AuthStatus.loading, errorMessage: null);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);

      await _updateState(status: AuthStatus.success);
    } catch (e) {
      await _updateState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    if (state.isLoading) return;

    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      state = const AuthState(
        status: AuthStatus.idle,
        errorMessage: null,
        user: null,
      );
    } catch (e) {
      // Logout failure is usually not critical
    }
  }

  // Reset status ke idle
  void resetStatus() {
    state = AuthState(
      status: AuthStatus.idle,
      errorMessage: null,
      user: state.user,
    );
  }

  // Helper error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Email tidak valid';
        case 'user-not-found':
          return 'Akun tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'weak-password':
          return 'Password minimal 6 karakter';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan';
        case 'popup-closed-by-user':
          return 'Login dibatalkan';
        default:
          return 'Authentication gagal. Coba lagi';
      }
    }
    return 'Terjadi kesalahan';
  }
}
