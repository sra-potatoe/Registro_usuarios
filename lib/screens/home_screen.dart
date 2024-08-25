import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import com.facebook.FacebookSdk;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${user?.displayName ?? 'Usuario'}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '¡Hola ${user?.displayName ?? 'Usuario'}!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
