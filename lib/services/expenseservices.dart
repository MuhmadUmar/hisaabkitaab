import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> addExpense(
    String userId, String title, String description, int expense) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add({
      'title': title,
      'description': description,
      'expense': expense,
    });

    if (kDebugMode) {
      print('Expense added successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error adding expense: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> fetchExpenses(String userId) async {
  try {
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    return expenseSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'title': doc['title'],
        'description': doc['description'],
        'expense': doc['expense'],
      };
    }).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching expenses: $e');
    }
    return [];
  }
}

Future<void> updateExpense(String userId, String expenseId, String title,
    String description, int expense) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .update({
      'title': title,
      'description': description,
      'expense': expense,
    });
  } catch (e) {
    if (kDebugMode) {
      print('Error updating expense: $e');
    }
  }
}

Future<void> deleteExpense(String userId, String expenseId) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();

    if (kDebugMode) {
      print('Expense deleted successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error deleting expense: $e');
    }
  }
}
