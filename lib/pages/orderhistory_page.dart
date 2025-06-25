import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          title: const Text("Order History"),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final transactions = snapshot.data!.docs;

              if (transactions.isEmpty) {
                return Center(
                  child: Text(
                    "No transaction history found.",
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final data =
                      transactions[index].data() as Map<String, dynamic>;
                  final List products = data['products'];
                  final double totalPrice =
                      (data['totalPrice'] as num).toDouble();
                  final String paymentMethod = data['paymentMethod'];
                  final String paymentDetails = data['paymentDetails'];
                  final Timestamp timestamp = data['timestamp'];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, color: accent),
                              const SizedBox(width: 8),
                              Text(
                                "Rp${totalPrice.toStringAsFixed(2)}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                formatDate(timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.payment, color: theme.iconTheme.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$paymentMethod • $paymentDetails",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text("Products:", style: theme.textTheme.titleSmall),
                          const SizedBox(height: 6),
                          ...products.map<Widget>((product) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 6),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "${product['name']} (x${product['quantity']})",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading data",
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
