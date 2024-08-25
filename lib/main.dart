import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'firebase_options.dart';
//import 'package:flutter_facebook_login';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

void initiateFacebookLogin() {
  //var login = FacebookLogin();
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
        title: 'Flutter Auth Demo',
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
      return const HomeScreen();
    }
    return const SignUpScreen(); // Se inicia en la pantalla de registro
  }
}
