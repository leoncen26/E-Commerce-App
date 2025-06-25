import 'package:ecommerce_app/profile/profile_page.dart';
import 'package:ecommerce_app/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'product_page.dart';
import 'cart_page.dart';
import 'checkout_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ProductPage(),
    CartPage(),
    CheckoutPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDark;
    return Scaffold(
      appBar: _selectedIndex == 4
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                leading: IconButton(
                onPressed: () {
                  theme.toggleMode(isDark);
                },
                icon: Icon(
                  isDark ? Icons.sunny : Icons.nightlight_outlined,
                )),
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
                title: const Text(
                  'Tech Zone',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      switch (value) {
                        case 'Order History':
                          Navigator.pushNamed(context, '/orderHistory');
                          break;
                        case 'Login / Register':
                          Navigator.pushNamed(context, '/logreg');
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'Order History',
                          child: Text('Order History'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Login / Register',
                          child: Text('Login / Register'),
                        ),
                      ];
                    },
                  ),
                ],
                backgroundColor: Colors.transparent,
              ),
            ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Checkout'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }
}
