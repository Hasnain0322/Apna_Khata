// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addExpense(String item, double amount, String category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).collection('expenses').add({
      'item': item,
      'amount': amount,
      'category': category,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Expense>> getExpensesStream() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(<Expense>[]);
      } else {
        return _db
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
      }
    });
  }

  // --- NEW DELETE METHOD ---
  Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;
    if (user == null) return; // Not logged in

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}