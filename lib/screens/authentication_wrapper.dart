import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/screens/sign_in_screen.dart';
import 'package:flutter_app/screens/sign_up_screen.dart';
import 'package:flutter_app/services/authentication_service.dart';
import 'package:flutter_app/screens/home_Screen.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    if (user != null) {
      // Si el usuario no ha verificado su correo, mostrar un mensaje
      if (!user.emailVerified) {
        return const SignUpScreen(); // O cualquier otra pantalla antes de la verificación
      }
      return const HomeScreen(); // Si el correo está verificado, mostrar la pantalla de inicio
    }
    return const SignUpScreen();
  }
}
