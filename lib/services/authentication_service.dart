import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.sendEmailVerification();

      // Deslogea hasta que el correo esté verificado
      await _firebaseAuth.signOut();
      // Solo muestra el mensaje en lugar de lanzar la excepción
      print(
          'Por favor, verifica tu correo electrónico antes de iniciar sesión.');
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'El correo electrónico ya está en uso. Por favor, utiliza otro correo o inicia sesión.';
          break;
        case 'too-many-requests':
          message =
              'Hemos bloqueado todas las solicitudes desde este dispositivo debido a actividad inusual. Intenta de nuevo más tarde.';
          break;
        default:
          message = 'Credenciales incorrectas, ingresa nuevamente tus datoss';
          break;
      }

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _firebaseAuth.signOut();
        // Solo muestra el mensaje en lugar de lanzar la excepción
        print(
            'Por favor, verifica tu correo electrónico antes de iniciar sesión.');
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

      throw FirebaseAuthException(
        code: e.code,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        User? user = _firebaseAuth.currentUser;
        await user?.reload();
        user = _firebaseAuth.currentUser;
        if (!user!.emailVerified) {
          await _firebaseAuth.signOut();
          // Solo muestra el mensaje en lugar de lanzar la excepción
          print(
              'Por favor, verifica tu correo electrónico antes de iniciar sesión.');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await _firebaseAuth.signInWithCredential(credential);

        // No se verifica el correo electrónico para usuarios de Facebook
        User? user = _firebaseAuth.currentUser;
        await user?.reload();
        user = _firebaseAuth.currentUser;

        // Redirigir al usuario a HomeScreen si ya está autenticado
        if (user != null) {
          // La sesión debería persistir aquí
        } else {
          throw FirebaseAuthException(
              code: 'facebook-auth-failed',
              message: 'Error al autenticar con Facebook.');
        }
      } else {
        throw FirebaseAuthException(
            code: 'facebook-auth-failed',
            message: 'Error al autenticar con Facebook: ${result.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Cierra sesión en Firebase
      await _firebaseAuth.signOut();

      // Cierra sesión en Google
      await GoogleSignIn().signOut();

      // Cierra sesión en Facebook
      await FacebookAuth.instance.logOut();
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> sendVerificationEmail() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
