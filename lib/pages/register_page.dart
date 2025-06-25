import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecommerce_app/main.dart';
// import 'package:ecommerce_app/pages/Auth_page.dart';
// import 'package:ecommerce_app/pages/login_page.dart';
// import 'package:ecommerce_app/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Package for formatting date

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;

  // New variables to handle password visibility
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // //show login page
  // bool showLoginPage = true;

  // void toggleScreens(){
  //   setState(() {
  //     showLoginPage = !showLoginPage;
  //   });
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Tambahkan detail pengguna ke database
        await addUserDetails(
          _userNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _phoneController.text.trim(),
          _selectedGender ?? 'Not Chosen',
          _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : 'Not Chosen',
        );

        // Setelah berhasil sign up, alihkan ke LoginPage
        widget.showLoginPage(); // Panggil fungsi untuk toggle ke halaman login
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future addUserDetails(String username, String email, String password,
      String phone, String gender, String dob) async {
    await FirebaseFirestore.instance.collection('users').add({
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'dob': dob,
    });
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
                // Icon
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

                // Welcome text
                Center(
                  child: Text(
                    'Welcome! To Tech Zone',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 50,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Username input field
                _buildTextField('Username', _userNameController),
                const SizedBox(height: 20),

                // Email input field
                _buildTextField('Email', _emailController),
                const SizedBox(height: 20),

                // Phone number input field
                _buildTextField('Phone Number', _phoneController),
                const SizedBox(height: 20),

                // Password input field
                _buildPasswordField(
                    'Password', _passwordController, _passwordVisible, () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                }),
                const SizedBox(height: 20),

                // Confirm Password input field
                _buildPasswordField('Confirm Password',
                    _confirmPasswordController, _confirmPasswordVisible, () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                }),
                const SizedBox(height: 20),

                // Gender dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: const Text('Select Gender'),
                      isExpanded: true,
                      underline: Container(),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'Female', child: Text('Female')),
                        DropdownMenuItem(
                            value: 'Not Chosen',
                            child: Text('Prefer not to say')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date of Birth Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date of Birth'
                            : 'DOB: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up button
                GestureDetector(
                  onTap: signUp,
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
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Already a member? Login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a member?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        ' Login now',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
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
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildPasswordField(String hintText, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
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
            obscureText: !isVisible,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: toggleVisibility,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
