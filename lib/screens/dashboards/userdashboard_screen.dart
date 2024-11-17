import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/screens/auth/login_screen.dart';
import 'package:hisaab_kitaab/utils/utils.dart';

class UserDashboardScreen extends StatefulWidget {
  final String username;
  const UserDashboardScreen({super.key, required this.username});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  User? currentUser;
  List<Map<String, dynamic>> userExpenses = [];
  int totalExpense = 0;
  int totalAdvance = 0;
  int balance = 0;

  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentUser(); // Reload data when returning to the screen
  }

  void logoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut().then((value) {
                Utils().toastMessage("Logged Out");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }).onError(
                (error, stackTrace) {
                  Utils().toastMessage(error.toString());
                },
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
      fetchUserData(user.uid); // Fetch expenses and advance data
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      // Fetch Expenses
      QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();
      int calculatedTotalExpense = 0;
      List<Map<String, dynamic>> expenses = expenseSnapshot.docs.map((doc) {
        calculatedTotalExpense += (doc['expense'] as int? ?? 0);
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'expense': doc['expense'],
        };
      }).toList();

      // Fetch Advance Payments
      QuerySnapshot advanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('advance_payments')
          .get();
      int calculatedTotalAdvance = 0;
      for (var doc in advanceSnapshot.docs) {
        calculatedTotalAdvance += (doc['amount'] as int? ?? 0);
      }

      // Calculate Balance
      int calculatedBalance = calculatedTotalAdvance - calculatedTotalExpense;

      setState(() {
        userExpenses = expenses;
        totalExpense = calculatedTotalExpense;
        totalAdvance = calculatedTotalAdvance;
        balance = calculatedBalance;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Expenses"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: logoutDialog,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (currentUser != null) {
            await fetchUserData(currentUser!.uid); // Refresh data
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Space between texts
                      children: [
                        Text(
                          'Advance: Rs $totalAdvance',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Expenses: Rs $totalExpense',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Balance: Rs $balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Expenses List
              userExpenses.isEmpty
                  ? const Center(child: Text('No expenses found'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: userExpenses.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> expense = userExpenses[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF232B21), // Dark shade
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                expense['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                expense['description'],
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              trailing: Text(
                                'Rs ${expense['expense']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
