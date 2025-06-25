// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/services/firestore.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirestoreService firestoreService = FirestoreService();

  // Kontroler untuk input produk
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openProductBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getRatedProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Product Available."));
          }

          final productsList = snapshot.data!;

          return ListView.builder(
            itemCount: productsList.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = productsList[index];
              String productId = product['id'];
              Map<String, dynamic> data = product['data'];
              double averageRating = product['averageRating'] ?? 0.0;

              String name = data['name'];
              String description = data['description'];
              double price = (data['price'] as num).toDouble();
              String imageUrl = data['imageUrl'];

              return Card(
                // Menggunakan Card untuk kotak produk
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(name),
                  subtitle: Text(
                      'Harga: Rp${price.toStringAsFixed(2)} | Rating: ${averageRating.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openProductBox(productId: productId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(productId);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: Colors.green),
                        onPressed: () {
                          _showAddToCartDialog(
                              name, description, price, imageUrl);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showProductDetails(
                        name, description, price, imageUrl, averageRating);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Menampilkan detail produk dalam dialog
  void _showProductDetails(String name, String description, double price,
      String imageUrl, double rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl,
                width: double.infinity, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text('Deskripsi: $description'),
            const SizedBox(height: 10),
            Text('Harga: Rp${price.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text('Rating: $rating'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(
      String name, String description, double price, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah ke Keranjang"),
        content: const Text("Tambahkan produk ini ke keranjang Anda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              firestoreService.addToCart(name, description, price, imageUrl);
              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await firestoreService.deleteProduct(productId);
              Navigator.pop(context); // Tutup dialog setelah menghapus
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void openProductBox({String? productId}) async {
    // Mengambil data produk jika mengedit
    if (productId != null) {
      final productData = await firestoreService.getProduct(productId);
      nameController.text = productData['name'];
      descriptionController.text = productData['description'];
      priceController.text = productData['price'].toString();
      imageUrlController.text = productData['imageUrl'];
      ratingController.text = productData['rating'].toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Membuat sudut dialog membulat
        ),
        title: Text(
          productId == null ? 'Add New Product' : 'Update Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3, // Sedikit bayangan
                margin: const EdgeInsets.symmetric(
                    vertical: 8), // Spasi antar input
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Membulatkan card
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          prefixIcon: const Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Gambar',
                          prefixIcon: const Icon(Icons.image),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: ratingController,
                        enabled: false, // Rating tidak bisa diubah
                        decoration: InputDecoration(
                          labelText: 'Rating',
                          prefixIcon: const Icon(Icons.star),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(productId == null ? Icons.add : Icons.update,
                      color: Colors.white),
                  label: Text(
                    productId == null ? "Add" : "Update",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: productId == null
                        ? Colors.green
                        : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final double price = double.parse(priceController.text);
                    final double rating =
                        double.tryParse(ratingController.text) ?? 0.0;

                    if (productId == null) {
                      await firestoreService.addProduct(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: price,
                        imageUrl: imageUrlController.text,
                        rating: rating,
                      );
                    } else {
                      await firestoreService.updateProduct(
                        productId: productId,
                        name: nameController.text,
                        description: descriptionController.text,
                        price: price,
                        imageUrl: imageUrlController.text,
                        rating: rating,
                      );
                    }

                  
                    nameController.clear();
                    descriptionController.clear();
                    priceController.clear();
                    imageUrlController.clear();
                    ratingController.clear();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
