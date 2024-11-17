import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/screens/advancemanagment_screen.dart';
import 'package:hisaab_kitaab/services/expenseservices.dart';

class UserExpenseScreen extends StatefulWidget {
  final String userId;
  const UserExpenseScreen({super.key, required this.userId});

  @override
  State<UserExpenseScreen> createState() => _UserExpenseScreenState();
}

class _UserExpenseScreenState extends State<UserExpenseScreen> {
  List<Map<String, dynamic>> expenses = [];
  String userName = 'Loading...';
  int totalExpense = 0;
  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchUserExpenses();
  }

  void fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['username'];
        });
      } else {
        setState(() {
          userName = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Error fetching name';
      });
    }
  }

  void fetchUserExpenses() async {
    List<Map<String, dynamic>> fetchedExpenses =
        await fetchExpenses(widget.userId);

    int calculatedTotalExpense = 0;
    for (var expense in fetchedExpenses) {
      if (expense['expense'] is int) {
        calculatedTotalExpense += expense['expense'] as int;
      } else if (expense['expense'] is String) {
        calculatedTotalExpense += int.tryParse(expense['expense']) ?? 0;
      }
    }

    setState(() {
      expenses = fetchedExpenses;
      totalExpense = calculatedTotalExpense;
    });
  }

  void showAddExpenseDialog() {
    String title = '';
    String description = '';
    int expenseAmount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Expense (Rs)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => expenseAmount = int.parse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await addExpense(
                  widget.userId, title, description, expenseAmount);
              fetchUserExpenses();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showTotalExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Total Expense'),
          content: Text('The total expense is Rs $totalExpense'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showEditExpenseDialog(String expenseId, String currentTitle,
      String currentDescription, int currentExpense) {
    String title = currentTitle;
    String description = currentDescription;
    int expenseAmount = currentExpense;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
              controller: TextEditingController(text: currentTitle),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
              controller: TextEditingController(text: currentDescription),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Expense (Rs)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => expenseAmount = int.parse(value),
              controller:
                  TextEditingController(text: currentExpense.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await updateExpense(
                  widget.userId, expenseId, title, description, expenseAmount);
              fetchUserExpenses();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showAllExpenseDeleteDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete all expenses"),
              content: const Text("Are you sure to delete all expenses?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      clearAllExpenses();
                      Navigator.pop(context);
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  void deleteExpenseDialog(String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await deleteExpense(widget.userId, expenseId);
              fetchUserExpenses();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void clearAllExpenses() async {
    try {
      QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('expenses')
          .get();

      for (var doc in expensesSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('expenses')
            .doc(doc.id)
            .delete();
      }

      setState(() {
        expenses.clear();
        totalExpense = 0;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All expenses cleared'),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing expenses: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error clearing expenses'),
      ));
    }
  }

  void clearAllDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Clear all expenses"),
              content: const Text("Are yousure to clear all expenses?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      clearAllExpenses();
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"))
              ],
            ));
  }

  void showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Expense'),
              onTap: () {
                Navigator.pop(context);
                showAddExpenseDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear All Expenses'),
              onTap: () {
                Navigator.pop(context);
                clearAllDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Show Total Expense'),
              onTap: () {
                Navigator.pop(context);
                showTotalExpenseDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Advance Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdvanceManagementScreen(userId: widget.userId)));
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
      backgroundColor: const Color(0xFF1F1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1E2C),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50),
        onPressed: showOptions,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses found'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> expense = expenses[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFF2C3E50), // Background color (darker shade)
                    borderRadius: BorderRadius.circular(6.0), // Rounded corners
                    // border: Border.all(color: Colors.black26), // Border color
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26, // Shadow color
                        blurRadius: 6.0, // Blur effect
                        offset: Offset(0, 3), // Position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      expense['title'],
                      style: const TextStyle(
                          color: Colors.white), // Title text color
                    ),
                    subtitle: Text(
                      expense['description'],
                      style: TextStyle(
                          color: Colors.grey.shade400), // Subtitle text color
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rs ${expense['expense']}',
                          style: const TextStyle(
                            color: Colors.white, // Expense text color
                            fontWeight: FontWeight.bold, // Bold for emphasis
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Spacing between text and popup menu
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white, // Popup icon color
                          ),
                          onSelected: (String result) {
                            if (result == 'edit') {
                              showEditExpenseDialog(
                                expense['id'],
                                expense['title'],
                                expense['description'],
                                expense['expense'],
                              );
                            } else if (result == 'delete') {
                              deleteExpenseDialog(expense['id']);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
