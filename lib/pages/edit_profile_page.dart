import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _docId; // To store the document ID from Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page opens
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first;
          _docId = userData.id;

          // Fill fields with user data
          setState(() {
            _usernameController.text = userData['username'];
            _emailController.text = userData['email'];
            _phoneController.text = userData['phone'];
            _selectedGender = userData['gender'];
            _selectedDate = DateTime.tryParse(userData['dob'] ?? '');
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User document not found')),
          );
        }
      } catch (e) {
        print('Error fetching user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUser(String username, String email, String phone,
      String gender, String dob, String password) async {
    if (_docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document ID found')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(_docId).update({
        'username': username,
        'email': email,
        'phone': phone,
        'gender': gender,
        'dob': dob,
        'password': password,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Failed to update user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Function to update user password
  Future<void> updatePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      } catch (e) {
        print('Failed to update password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $e')),
        );
      }
    }
  }

  // Function to validate input
  bool _validateInput() {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return false;
    }
    return true;
  }

  // Function to save changes
  Future<void> _saveChanges() async {
    if (_validateInput()) {
      final username = _usernameController.text.trim();
      await updateUser(
        username,
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _selectedGender ?? 'Not Specified',
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : 'Not Chosen',
        _passwordController.text.trim(),
      );

      if (_passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text) {
        await updatePassword(_passwordController.text.trim());
      } else if (_passwordController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  // Function to select date of birth
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Set the same AppBar color
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100], // Consistent background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        enabled: false, // Email cannot be changed
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        hint: const Text('Select Gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'Female', child: Text('Female')),
                          DropdownMenuItem(
                              value: 'Not Specified',
                              child: Text('Prefer not to say')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.transgender),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(
                              text: _selectedDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!)
                                  : 'Select Date of Birth',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text(
                          'Save Changes',
                           style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple, // Consistent button color
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
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
      ),
    );
  }
}
