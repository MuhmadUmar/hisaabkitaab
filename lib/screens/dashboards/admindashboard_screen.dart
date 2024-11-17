import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/models/UserModel.dart';
import 'package:hisaab_kitaab/screens/auth/login_screen.dart';
import 'package:hisaab_kitaab/screens/userexpense_screen.dart';
import 'package:hisaab_kitaab/utils/utils.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  const AdminDashboardScreen({super.key, required this.username});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final auth = FirebaseAuth.instance;
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    List<UserModel> fetchedUsers = await getAllUsers();
    setState(() {
      users = fetchedUsers;
      isLoading = false;
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();

    return userSnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addSpecialExpense() async {
    String title = '';
    String description = '';
    int totalAmount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shared Expense'),
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
              decoration: const InputDecoration(labelText: 'Total Amount (Rs)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => totalAmount = int.tryParse(value) ?? 0,
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
              if (title.isNotEmpty && totalAmount > 0 && users.isNotEmpty) {
                int dividedAmount = (totalAmount / users.length).round();
                for (var user in users) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.id)
                      .collection('expenses')
                      .add({
                    'title': title,
                    'description': description,
                    'expense': dividedAmount,
                  });
                }

                Utils().toastMessage('Shared expense added successfully');
                fetchUsers(); // Refresh the user data after adding expense
                Navigator.pop(context);
              } else {
                Utils().toastMessage('Please fill in all fields.');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<int> fetchBalance(String userId) async {
    int totalExpenses = 0;
    int totalAdvance = 0;

    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();
    for (var doc in expenseSnapshot.docs) {
      totalExpenses += doc['expense'] as int;
    }

    QuerySnapshot advanceSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('advance_payments')
        .get();
    for (var doc in advanceSnapshot.docs) {
      totalAdvance += doc['amount'] as int;
    }

    return totalAdvance - totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1F1E2C),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Utils().toastMessage("Logged Out");
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }).onError((error, stackTrace) {
                Utils().toastMessage(error.toString());
              });
            },
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUsers,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Registered Users: ${users.length}',
                    //   style: const TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          UserModel user = users[index];
                          return FutureBuilder<int>(
                            future: fetchBalance(user.id),
                            builder: (context, snapshot) {
                              // if (snapshot.connectionState ==
                              //     ConnectionState.waiting) {
                              //   return const Center(
                              //       child: CircularProgressIndicator());
                              // }
                              int balance = snapshot.data ?? 0;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C3E50),
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6.0,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Balance: Rs $balance',
                                    style: TextStyle(
                                      color: balance >= 0
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserExpenseScreen(
                                          userId: user.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSpecialExpense,

        tooltip: 'Add Special Expense',
        backgroundColor: const Color(0xFF2C3E50),
        child: const Icon(Icons.add), // Purple color for FAB
      ),
      backgroundColor: const Color(0xFF1E1E2C),
    );
  }
}
