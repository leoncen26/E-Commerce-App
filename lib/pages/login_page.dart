// import 'package:ecommerce_app/main.dart';
import 'package:ecommerce_app/pages/Auth_page.dart';
import 'package:ecommerce_app/pages/forgot_pass_page.dart';
import 'package:ecommerce_app/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // State to track password visibility

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the main page if login is successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const MainPage(); // Page after successful login
                } else {
                  return const AuthPage(); // Login/registration page
                }
              },
            ),
          ),
        ),
      );
    } catch (e) {
      // Handle login error
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Hello again text
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 50,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                Text('To Tech Zone',
                style: GoogleFonts.bebasNeue(
                    fontSize: 50,
                    color: Colors.deepPurpleAccent,
                ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Log in to your account',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email input field
                _buildTextField(_emailController, 'Email', false),
                const SizedBox(height: 20),

                // Password input field with visibility toggle
                _buildPasswordField(_passwordController, 'Password'),
                const SizedBox(height: 10),

                // Forgot password link
                _buildForgotPasswordLink(context),
                const SizedBox(height: 20),

                // Sign in button
                _buildSignInButton(),
                const SizedBox(height: 40),

                // Registration prompt
                _buildRegistrationPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !_isPasswordVisible, // Toggle visibility
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: signIn,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Not a member?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        GestureDetector(
          onTap: widget.showRegisterPage,
          child: const Text(
            ' Register now',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
