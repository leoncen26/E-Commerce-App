import 'package:ecommerce_app/component/app_theme.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:ecommerce_app/pages/Auth_page.dart';
import 'package:ecommerce_app/pages/checkout_page.dart';
import 'package:ecommerce_app/pages/main_page.dart';
import 'package:ecommerce_app/pages/orderhistory_page.dart';
import 'package:ecommerce_app/profile/profile_page.dart';
import 'package:ecommerce_app/provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tech Zone',
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.theme,
      home: const AuthWrapper(),
      routes: {
        '/checkoutPage': (context) => const CheckoutPage(),
        '/orderHistory': (context) => const OrderHistoryPage(),
        '/logreg': (context) => const AuthPage(),
        '/profile': (context) => const ProfilePage(),
        '/mainPage': (context) => const MainPage(),
      },
      initialRoute: '/mainPage',
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading indikator
          } else if (snapshot.hasData) {
            return const MainPage(); // User logged in, tampilkan halaman utama
          } else {
            return const AuthPage(); // User belum login, tampilkan halaman login
          }
        },
      ),
    );
  }
}
