import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Note: file_picker and review_expenses_screen imports are removed.
import 'package:expense_tracker/services/ai_service.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final AiService _aiService = AiService();

  /// Handles scanning a receipt image by uploading it to the backend.
  Future<void> _scanReceipt() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    
    _showProcessingSnackbar('Uploading and analyzing receipt...');
    final result = await _aiService.analyzeReceiptImage(image.path);
    _handleServiceResult(result);
  }

  // Helper methods for UI feedback and navigation
  void _showProcessingSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error));
  }
  
  void _handleServiceResult(Map<String, dynamic>? result) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (result != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpenseScreen(initialData: result)));
    } else {
      _showErrorSnackbar('Could not process your request. Please try again.');
    }
  }

  /// Shows the logout confirmation dialog.
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _auth.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildActionButton(context, icon: Icons.receipt_long, label: 'Scan Receipt', onPressed: _scanReceipt),
                        _buildActionButton(context, icon: Icons.picture_as_pdf, label: 'Parse PDF', onPressed: () {
                          _showErrorSnackbar('PDF Parsing feature is coming soon!');
                        }),
                        _buildActionButton(context, icon: Icons.mic, label: 'Voice Entry', onPressed: () {
                          _showErrorSnackbar('Voice Entry feature is coming soon!');
                        }),
                        _buildActionButton(context, icon: Icons.edit_note, label: 'Text Entry', onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Reports Section
                    _buildSectionHeader('Reports'),
                    const SizedBox(height: 16),
                    _buildActionButton(context, icon: Icons.calendar_today, label: 'Monthly Report', onPressed: () {}, isFullWidth: true),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildActionButton(context, icon: Icons.calendar_view_week, label: 'Yearly Report', onPressed: () {}),
                        _buildActionButton(context, icon: Icons.edit_calendar, label: 'Custom Report', onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Personal Section
                    _buildSectionHeader('Personal'),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildActionButton(context, icon: Icons.person_outline, label: 'Profile', onPressed: () {}),
                        _buildActionButton(context, icon: Icons.settings_outlined, label: 'Settings', onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed, bool isFullWidth = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 12),
            Text(label, textAlign: isFullWidth ? TextAlign.start : TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}