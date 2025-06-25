import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uuid/uuid.dart';

class FirestoreService {
  // Get Collection of Products
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  // Get Collection of Carts
  final CollectionReference cart =
      FirebaseFirestore.instance.collection('cart');
  // Get Collection of Carts
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');
  // Get Collection of Feedbacks
  final CollectionReference feedbacks =
      FirebaseFirestore.instance.collection('feedbacks');

  // Method untuk mendapatkan stream feedbacks (jika diperlukan)
  Stream<QuerySnapshot> getFeedbackStream() {
    return feedbacks.orderBy('timestamp', descending: true).snapshots();
  }

  // Stream untuk produk beserta rata-rata rating
  Stream<List<Map<String, dynamic>>> getRatedProductsStream() {
    return products.snapshots().asyncMap((QuerySnapshot productSnapshot) async {
      List<Map<String, dynamic>> productList = [];

      // Loop setiap produk untuk menghitung rata-rata rating
      for (var doc in productSnapshot.docs) {
        Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;
        String productName = productData['name']; // Ambil nama produk

        // Dapatkan rata-rata rating dari feedback untuk produk ini
        double averageRating = await _getAverageRatingForProduct(productName);

        // Tambahkan data produk dan rating ke daftar
        productList.add({
          'id': doc.id, // Tetap simpan product ID untuk referensi
          'data': productData,
          'averageRating': averageRating,
        });
      }

      return productList;
    });
  }

// Metode untuk menghitung rata-rata rating berdasarkan nama produk
  Future<double> _getAverageRatingForProduct(String productName) async {
    // Gunakan 'product' untuk mencari feedback berdasarkan nama produk
    QuerySnapshot feedbackSnapshot =
        await feedbacks.where('product', isEqualTo: productName).get();

    if (feedbackSnapshot.docs.isEmpty) {
      return 0.0;
    }

    
    double totalRating = 0;
    feedbackSnapshot.docs.forEach((doc) {
      totalRating +=
          (doc['rating'] as num).toDouble(); // Pastikan konversi ke double
    });

    return totalRating / feedbackSnapshot.docs.length;
  }

  // CREATE: Add a new product with simple ID format
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    double rating = 0.0, // Default rating 0.0
  }) async {
    // Ambil semua produk untuk menghitung ID baru
    QuerySnapshot allProducts = await products.get();
    int newIdNumber = allProducts.docs.length + 1; // Hitung total produk

    String productId =
        'P${newIdNumber.toString().padLeft(2, '0')}'; // Generate ID like P01, P02

    return products.doc(productId).set({
      'id': productId, // Store unique ID
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'timestamp': Timestamp.now(),
    });
  }

  // Method untuk mengambil semua produk
  Future<QuerySnapshot> getAllProducts() async {
    return await products.get(); // Mengambil semua dokumen dari koleksi 'products'
  }

// READ: Get a stream of products ordered by timestamp
  Stream<QuerySnapshot> getProductsStream() {
    return products.orderBy('timestamp', descending: true).snapshots();
  }

// READ: Get a single product by its document ID
  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await products.doc(productId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      rethrow; // Handle errors if needed
    }
  }

// UPDATE: Update product given a document ID
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    double? rating, // Optional: Update rating if provided
  }) async {
    Map<String, dynamic> updatedData = {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    };

    if (rating != null) {
      updatedData['rating'] = rating; // Update rating if passed
    }

    return products.doc(productId).update(updatedData);
  }

// DELETE: Delete product given a document ID
  Future<void> deleteProduct(String productId) async {
    return products.doc(productId).delete();
  }


  // CRUD for Carts
  // Add product to cart or update quantity if already exists
  Future<void> addToCart(
      String name, String description, double price, String imageUrl) async {
    // Check if the product already exists in the cart
    QuerySnapshot existingProduct =
        await cart.where('name', isEqualTo: name).limit(1).get();

    if (existingProduct.docs.isNotEmpty) {
      // If product exists, update the quantity
      DocumentSnapshot existingDoc = existingProduct.docs.first;

      // Safely access 'quantity' with a fallback value of 1 if it doesn't exist
      int currentQuantity =
          (existingDoc.data() as Map<String, dynamic>)['quantity'] ?? 1;

      cart.doc(existingDoc.id).update({
        'quantity': currentQuantity + 1,
        'timestamp': Timestamp.now(),
      });
    } else {
      // If product doesn't exist, add it with quantity 1
      cart.add({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': 1, // New field for quantity
        'timestamp': Timestamp.now(),
      });
    }
  }

// Update cart item quantity
  Future<void> updateCartItemQuantity(String docID, int quantity) {
    return cart.doc(docID).update({
      'quantity': quantity,
      'timestamp': Timestamp.now(),
    });
  }

  // Get cart items
  Stream<QuerySnapshot> getCartStream() {
    return cart.orderBy('timestamp', descending: true).snapshots();
  }

  // Update cart item
  Future<void> updateCartItem(String docID, String name, String description,
      double price, String imageUrl) {
    return cart.doc(docID).update({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete cart item
  Future<void> deleteCartItem(String docID) {
    return cart.doc(docID).delete();
  }

  // Update quantity of cart item
  Future<void> updateCartQuantity(String docID, int newQuantity) {
    return cart.doc(docID).update({
      'quantity': newQuantity,
      'timestamp': Timestamp.now(), // Optionally update timestamp
    });
  }

  // Delete all items from the cart
  Future<void> clearCart() async {
    QuerySnapshot cartItems = await cart.get();
    for (DocumentSnapshot doc in cartItems.docs) {
      await doc.reference.delete();
    }
  }

  // CRUD for Transactions
  // Save completed transaction to Firestore
  Future<void> saveTransaction(List<Map<String, dynamic>> products,
      double totalPrice, String paymentMethod, String paymentDetails) {
    return FirebaseFirestore.instance.collection('transactions').add({
      'products': products,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'timestamp': Timestamp.now(),
    });
  }

  //CRUD for Login & Register
  // CREATE: Register a new user
  // Future<void> createUser(String email, String password, String username) {
  //   return _db.collection('users').add({
  //     'email': email,
  //     'password': password, // In a real app, hash this password
  //     'username': username,
  //     'createdAt': Timestamp.now(),
  //   });
  // }

  // // READ: Fetch user by email (for login)
  // final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  //   try {
  //     QuerySnapshot snapshot = await _db
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .limit(1)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       return snapshot.docs.first.data() as Map<String, dynamic>;
  //     }
  //   } catch (e) {
  //     print("Error getting user data: $e");
  //   }
  //   return null;
  // }
}
