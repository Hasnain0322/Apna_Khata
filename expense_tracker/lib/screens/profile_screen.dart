import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Shows a confirmation dialog before sending a password reset email.
  Future<void> _showPasswordResetDialog(BuildContext context, AuthService auth) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Text('A password reset link will be sent to your email address. Do you want to continue?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Send Email'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog first
                final success = await auth.sendPasswordResetEmail();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Colors.green),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not send email. Please try again.'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dangerous action confirmation dialog before deleting an account.
  Future<void> _showDeleteAccountDialog(BuildContext context, AuthService auth) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must explicitly choose
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('⚠️ Delete Account?'),
          content: const Text('This action is permanent and cannot be undone. All your data will be lost. Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete My Account'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await auth.deleteUserAccount();
                if (!success && context.mounted) {
                  // Inform user if re-authentication is needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not delete account. Please log out and log back in to continue.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                // On success, AuthGate handles navigation automatically.
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: <Widget>[
          // User Info Header
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Logged in as:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'No email found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          const Divider(),

          // Menu Options
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change Password'),
            onTap: () {
              _showPasswordResetDialog(context, auth);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              _showDeleteAccountDialog(context, auth);
            },
          ),
        ],
      ),
    );
  }
}