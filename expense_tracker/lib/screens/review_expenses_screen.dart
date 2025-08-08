import 'package:flutter/material.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/glass_card.dart';

class ReviewExpensesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> foundExpenses;

  const ReviewExpensesScreen({super.key, required this.foundExpenses});

  @override
  State<ReviewExpensesScreen> createState() => _ReviewExpensesScreenState();
}

class _ReviewExpensesScreenState extends State<ReviewExpensesScreen> {
  late List<bool> _selected;
  final _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize all found expenses as selected by default
    _selected = List<bool>.filled(widget.foundExpenses.length, true);
  }

  Future<void> _importSelectedExpenses() async {
    setState(() => _isSaving = true);
    int importCount = 0;

    for (int i = 0; i < widget.foundExpenses.length; i++) {
      if (_selected[i]) {
        final expense = widget.foundExpenses[i];
        await _firestoreService.addExpense(
          expense['item'],
          expense['amount'],
          expense['category'],
        );
        importCount++;
      }
    }

    if (mounted) {
      Navigator.of(context).pop(); // Go back to the HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported $importCount expenses!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selected.where((item) => item == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Import')),
      body: widget.foundExpenses.isEmpty
          ? const Center(child: Text('No debit transactions were found in the PDF.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Padding to avoid FAB overlap
              itemCount: widget.foundExpenses.length,
              itemBuilder: (context, index) {
                final expense = widget.foundExpenses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CheckboxListTile(
                      title: Text(expense['item'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(expense['category']),
                      secondary: Text('₹${expense['amount'].toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      value: _selected[index],
                      onChanged: (bool? value) {
                        setState(() {
                          _selected[index] = value!;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _isSaving
          ? FloatingActionButton(onPressed: null, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary))
          : FloatingActionButton.extended(
              onPressed: selectedCount > 0 ? _importSelectedExpenses : null,
              label: Text('Import ($selectedCount)'),
              icon: const Icon(Icons.download_done),
              backgroundColor: selectedCount > 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
    );
  }
}