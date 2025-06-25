import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirestoreService firestoreService = FirestoreService();
  String paymentMethod = "Credit Card";
  TextEditingController _paymentDetailsController = TextEditingController();
  double _rating = 0.0;
  TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          List cartList = snapshot.data!.docs;
          double totalPrice = 0.0;

          for (var document in cartList) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            double price = (data['price'] as num).toDouble();
            int quantity = data['quantity'] ?? 1;
            totalPrice += price * quantity;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Summary:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 5,
                    child: ListView.builder(
                      itemCount: cartList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = cartList[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String name = data['name'];
                        double price = (data['price'] as num).toDouble();

                        int quantity = data['quantity'] ?? 1;

                        return ListTile(
                          title: Text(name),
                          subtitle: Text("Quantity: $quantity"),
                          trailing: Text(
                            '\Rp${(price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Total: \Rp${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select Payment Method:",
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: paymentMethod,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "Credit Card",
                        child: Text("Credit Card"),
                      ),
                      DropdownMenuItem(
                        value: "Tunai",
                        child: Text("Tunai"),
                      ),
                      DropdownMenuItem(
                        value: "Bank Transfer",
                        child: Text("Bank Transfer"),
                      ),
                      DropdownMenuItem(
                        value: "E-Wallet",
                        child: Text("E-Wallet"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _paymentDetailsController,
                    decoration: const InputDecoration(
                      labelText: "Enter Payment Details",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(300, 70),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        _completePurchase(totalPrice);
                      },
                      child: const Text(
                        "Complete Purchase",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _completePurchase(double totalPrice) async {
    try {
      List<Map<String, dynamic>> purchasedProducts = [];
      QuerySnapshot cartSnapshot = await firestoreService.getCartStream().first;
      for (var doc in cartSnapshot.docs) {
        purchasedProducts.add(doc.data() as Map<String, dynamic>);
      }

      Map<String, dynamic> transactionData = {
        'products': purchasedProducts,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'paymentDetails': _paymentDetailsController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transactionData);
      await firestoreService.clearCart();
      _showSuccessDialog();

      for (var product in purchasedProducts) {
        _showRatingDialog(product['name']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Purchase Successful'),
          content: const Text('Thank you for your purchase!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(String productName) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Rate $productName"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please rate the product:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1.0;
                        });
                      },
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: index < _rating ? Colors.amber : Colors.grey,
                        size: 40.0,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    labelText: "Enter your feedback",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_rating < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please rate at least 1 star.')),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('feedbacks').add({
                    'product': productName,
                    'rating': _rating,
                    'feedback': _feedbackController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  _feedbackController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }
}
