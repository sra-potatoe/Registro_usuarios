import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_in_screen.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null || (user.providerData.every((info) => info.providerId != "facebook.com") && !user.emailVerified)) {
      // Usamos WidgetsBinding para evitar la redirección en el build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthenticationService>().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenido, ${user.displayName ?? 'Usuario'}!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
