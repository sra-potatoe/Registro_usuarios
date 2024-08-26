import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    try {
      await context.read<AuthenticationService>().signInWithEmail(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      // Verifica si el correo electrónico del usuario está verificado
      final user = context.read<AuthenticationService>().getCurrentUser();
      if (user != null && !user.emailVerified) {
        await _showVerificationMessage();
        await context.read<AuthenticationService>().signOut();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// Método para mostrar el mensaje toast en lugar de redirigir o recargar
  Future<void> _showVerificationMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, verifica tu correo electrónico.'),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      await context.read<AuthenticationService>().signInWithGoogle();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      await context.read<AuthenticationService>().signInWithFacebook();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Inicia sesión',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signInWithEmail,
                child: const Text('Iniciar sesión con Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Iniciar sesión con Google'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithFacebook,
                child: const Text('Iniciar sesión con Facebook'),
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text('¿No tienes una cuenta? Regístrate'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
