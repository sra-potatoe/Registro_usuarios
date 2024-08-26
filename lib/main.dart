import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';
import 'services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/sign_up_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user != null) {
      final isEmailSignIn = user.providerData.any((info) =>
          info.providerId == "password" || info.providerId == "google.com");

      if (isEmailSignIn && !user.emailVerified) {
        // Mostrar el mensaje de verificación
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, verifica tu correo electrónico.'),
            ),
          );
        });

        // Mostrar la pantalla de verificación con la opción de reenvío de correo
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Por favor, verifica tu correo electrónico.'),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await context
                          .read<AuthenticationService>()
                          .sendVerificationEmail();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Correo de verificación reenviado.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Reenviar correo de verificación'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                  },
                  child: const Text('Iniciar sesión con otra cuenta'),
                ),
              ],
            ),
          ),
        );
      } else {
        return const HomeScreen();
      }
    }

    return const SignUpScreen();
  }
}





/*
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user != null) {
      // Solo manejar la verificación de correo si se autenticó con email o Google
      final isEmailSignIn = user.providerData.any((info) =>
          info.providerId == "password" || info.providerId == "google.com");

      if (isEmailSignIn && !user.emailVerified) {
        // Verifica el estado del correo electrónico después de un retraso
        Future<void> checkEmailVerification() async {
          while (true) {
            await Future.delayed(Duration(seconds: 5)); // Revisa cada 5 segundos
            await user.reload();
            final updatedUser = FirebaseAuth.instance.currentUser;
            if (updatedUser != null && updatedUser.emailVerified) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break; // Sale del bucle cuando el correo está verificado
            }
          }
        }

        checkEmailVerification();

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Por favor, verifica tu correo electrónico.'),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await context
                          .read<AuthenticationService>()
                          .sendVerificationEmail();
                    }
                  },
                  child: const Text('Reenviar correo de verificación'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                  child: const Text('Iniciar sesión con otra cuenta'),
                ),
              ],
            ),
          ),
        );
      } else {
        return const HomeScreen();
      }
    }

    // Redirige a la pantalla de registro si no hay usuario autenticado
    return const SignUpScreen();
  }
}
*/