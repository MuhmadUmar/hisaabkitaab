import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdvanceManagementScreen extends StatefulWidget {
  final String userId; // User ID for whom the advance payments are managed
  const AdvanceManagementScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _AdvanceManagementScreenState createState() =>
      _AdvanceManagementScreenState();
}

class _AdvanceManagementScreenState extends State<AdvanceManagementScreen> {
  List<Map<String, dynamic>> advancePayments = [];

  @override
  void initState() {
    super.initState();
    fetchAdvancePayments(); // Fetch advance payments on screen load
  }

  // Fetch advance payments for the user from Firestore
  void fetchAdvancePayments() async {
    try {
      QuerySnapshot advanceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('advance_payments')
          .get();

      List<Map<String, dynamic>> payments = advanceSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'amount': doc['amount'],
          'date': (doc['date'] as Timestamp)
              .toDate(), // Convert Firestore Timestamp to DateTime
          'description': doc['description'],
        };
      }).toList();

      setState(() {
        advancePayments = payments;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching advance payments: $e');
      }
    }
  }

  // Function to add or edit advance payment
  void showAdvancePaymentDialog(
      {String? paymentId, Map<String, dynamic>? payment}) {
    String description = payment?['description'] ?? '';
    int amount = payment?['amount'] ?? 0;
    DateTime selectedDate = payment?['date'] ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            paymentId == null ? 'Add Advance Payment' : 'Edit Advance Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
              controller: TextEditingController(text: description),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount (Rs)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = int.parse(value),
              controller: TextEditingController(text: amount.toString()),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                  'Pick Payment Date: ${selectedDate.toLocal()}'.split(' ')[0]),
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
              // If paymentId is null, it's a new payment, otherwise it's an edit
              if (paymentId == null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('advance_payments')
                    .add({
                  'amount': amount,
                  'date': selectedDate,
                  'description': description,
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('advance_payments')
                    .doc(paymentId)
                    .update({
                  'amount': amount,
                  'date': selectedDate,
                  'description': description,
                });
              }

              fetchAdvancePayments(); // Refresh the list after adding/editing
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: Text(paymentId == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Function to delete an advance payment
  void deleteAdvancePayment(String paymentId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('advance_payments')
        .doc(paymentId)
        .delete();

    fetchAdvancePayments(); // Refresh the list after deletion
  }

  void clearAllAdvancePayments() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear'),
        content: const Text(
            'Are you sure you want to clear all advance payments? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // User cancels
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // User confirms
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        // Fetch all advance payments and delete each one
        QuerySnapshot advanceSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('advance_payments')
            .get();

        for (var doc in advanceSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('advance_payments')
              .doc(doc.id)
              .delete();
        }

        setState(() {
          advancePayments.clear(); // Clear the local list of advance payments
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('All advance payments cleared.'),
        ));
      } catch (e) {
        if (kDebugMode) {
          print('Error clearing advance payments: $e');
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error clearing advance payments.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Advance Payments',
              style: TextStyle(fontWeight: FontWeight.w500)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: clearAllAdvancePayments, // Clear all advance payments
              tooltip: 'Clear All Advance Payments',
            ),
          ]),
      body: advancePayments.isEmpty
          ? const Center(child: Text('No advance payments found'))
          : ListView.builder(
              itemCount: advancePayments.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> payment = advancePayments[index];
                return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Margin around the tile
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF232B21), // Background color (darker shade)
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded corners
                      border: Border.all(
                          color: Colors.grey.shade700), // Border color
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
                        'Rs ${payment['amount']}',
                        style: const TextStyle(
                            color: Colors.white), // Title text color
                      ),
                      subtitle: Text(
                        // Check if the payment date is valid and format it
                        payment['date'] != null
                            ? 'Date: ${DateTime.fromMillisecondsSinceEpoch(payment['date'].millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}'
                            : 'Date: N/A', // Default text if date is null
                        style: TextStyle(
                            color: Colors.grey.shade400), // Subtitle text color
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white, // Popup icon color
                        ),
                        onSelected: (String result) {
                          if (result == 'edit') {
                            showAdvancePaymentDialog(
                              paymentId: payment['id'],
                              payment: payment,
                            ); // Edit
                          } else if (result == 'delete') {
                            deleteAdvancePayment(payment['id']); // Delete
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
                    ));
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAdvancePaymentDialog(),
        tooltip: 'Add Advance Payment', // Add new advance payment
        child: const Icon(Icons.add),
      ),
    );
  }
}
