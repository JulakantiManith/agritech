import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> handleLogin() async {
    try {
      await AuthService.login(
        emailController.text.trim(  ),
        passwordController.text.trim(),
      );

      await AuthService.fetchJwtToken();

    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  Future<void> handleSignup() async {
    try {
      await AuthService.signup(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await AuthService.fetchJwtToken();

    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  Future<void> handleGoogleLogin() async {
    try {
      await AuthService.signInWithGoogle();
      await AuthService.fetchJwtToken();
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: handleLogin,
              child: const Text("Login"),
            ),

            ElevatedButton(
              onPressed: handleSignup,
              child: const Text("Signup"),
            ),

            ElevatedButton(
              onPressed: handleGoogleLogin,
              child: const Text("Sign in with Google"),
            ),

            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
