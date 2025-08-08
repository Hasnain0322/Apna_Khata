import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/screens/main_app_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while Firebase is checking the auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the snapshot has data, the user is logged in.
        if (snapshot.hasData) {
          // User is signed in, show the main application shell.
          return const MainAppShell();
        }

        // If the snapshot has no data, the user is not signed in.
        return const LoginScreen();
      },
    );
  }
}