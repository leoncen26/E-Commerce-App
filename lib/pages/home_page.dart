// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/pages/product_detail_page.dart';
import 'package:ecommerce_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getRatedProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> productsList = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: productsList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> productWithRating = productsList[index];
                  String docID = productWithRating['id'];
                  Map<String, dynamic> data = productWithRating['data'];
                  double averageRating = productWithRating['averageRating'];

                  String name = data['name'];
                  String description = data['description'];
                  double price = (data['price'] as num).toDouble();
                  String imageUrl = data['imageUrl'];

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        navigateToProductDetail(context, name, description, price, imageUrl, docID, averageRating);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Rp${price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Rating: ${averageRating.toStringAsFixed(2)} ⭐',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Method to navigate to the product detail page
  void navigateToProductDetail(BuildContext context, String name, String description,
      double price, String imageUrl, String docID, double averageRating) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          docID: docID,
          averageRating: averageRating,
        ),
      ),
    );
  }
}
