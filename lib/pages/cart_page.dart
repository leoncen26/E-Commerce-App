import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/services/firestore.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<DocumentSnapshot> cartList = []; // Menyimpan item keranjang
  double totalPrice = 0.0; // Menyimpan total harga

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan pada cart stream
    firestoreService.getCartStream().listen((snapshot) {
      setState(() {
        cartList = snapshot.docs; // Memperbarui cartList dengan data terbaru
        totalPrice = _calculateTotalPrice(); // Hitung total harga
      });
    });
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    for (var document in cartList) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      double price = (data['price'] as num).toDouble();

      int quantity = data['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cartList.isNotEmpty
          ? Column(
              children: [
                // List item dalam keranjang
                Expanded(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = cartList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String name = data['name'];
                      double price = (data['price'] as num).toDouble();

                      String imageUrl = data['imageUrl'];
                      int quantity = data['quantity'] ?? 1;
                      double subtotal = price * quantity;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \Rp${price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.grey)),
                              Text(
                                  'Subtotal: \Rp${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Minus button
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    firestoreService.updateCartQuantity(
                                        docID, quantity - 1);
                                    setState(() {
                                      data['quantity'] = quantity -
                                          1; // Update quantity locally
                                      totalPrice =
                                          _calculateTotalPrice(); // Update total price
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              // Quantity display
                              Text('$quantity',
                                  style: const TextStyle(fontSize: 16)),
                              // Plus button
                              IconButton(
                                onPressed: () {
                                  firestoreService.updateCartQuantity(
                                      docID, quantity + 1);
                                  setState(() {
                                    data['quantity'] =
                                        quantity + 1; // Update quantity locally
                                    totalPrice =
                                        _calculateTotalPrice(); // Update total price
                                  });
                                },
                                icon: const Icon(Icons.add),
                              ),
                              // Delete button
                              IconButton(
                                onPressed: () {
                                  firestoreService.deleteCartItem(docID);
                                  setState(() {
                                    cartList
                                        .removeAt(index); // Remove item locally
                                    totalPrice =
                                        _calculateTotalPrice(); // Update total price
                                  });
                                },
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total harga dan tombol checkout di bagian bawah
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total harga
                      Row(
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\Rp${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Tombol checkout
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Set color here
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkoutPage');
                        },
                        child: const Text("Pesan Sekarang",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: Text("No items in cart.")),
    );
  }
}
