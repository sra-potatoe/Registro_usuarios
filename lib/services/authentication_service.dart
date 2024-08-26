import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Getter para authStateChanges
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;
      await user.updateProfile(displayName: name);
      await user.sendEmailVerification();

      // Deslogea hasta que el correo esté verificado
      await _firebaseAuth.signOut();
      print('Por favor, verifica tu correo electrónico antes de iniciar sesión.');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'El correo electrónico ya está en uso. Por favor, utiliza otro correo o inicia sesión.';
          break;
        case 'too-many-requests':
          message = 'Hemos bloqueado todas las solicitudes desde este dispositivo debido a actividad inusual. Intenta de nuevo más tarde.';
          break;
        default:
          message = 'Ocurrió un error. Por favor, intenta nuevamente.';
          break;
      }
      throw FirebaseAuthException(code: e.code, message: message);
    } catch (e) {
      print('Error desconocido: $e');
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;
      if (!user.emailVerified) {
        await _firebaseAuth.signOut();
        print('Por favor, verifica tu correo electrónico antes de iniciar sesión.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No se encontró una cuenta con ese correo electrónico.';
          break;
        case 'wrong-password':
          message = 'La contraseña ingresada es incorrecta.';
          break;
        default:
          message = 'Ocurrió un error. Por favor, intenta nuevamente.';
          break;
      }
      throw FirebaseAuthException(code: e.code, message: message);
    } catch (e) {
      print('Error desconocido: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        final User user = userCredential.user!;
        if (!user.emailVerified) {
          await _firebaseAuth.signOut();
          print('Por favor, verifica tu correo electrónico antes de iniciar sesión.');
        }
      }
    } catch (e) {
      print('Error de autenticación con Google: $e');
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        final User user = userCredential.user!;
        // No es necesario verificar el correo para Facebook
      } else {
        throw FirebaseAuthException(
            code: 'facebook-auth-failed',
            message: 'Error al autenticar con Facebook: ${result.message}');
      }
    } catch (e) {
      print('Error de autenticación con Facebook: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> sendVerificationEmail() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
