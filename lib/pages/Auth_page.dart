import 'package:ecommerce_app/pages/login_page.dart';
import 'package:ecommerce_app/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  
  //show login page
  bool showLoginPage = true;

  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(showRegisterPage:toggleScreens);
    } else{
      return RegisterPage(showLoginPage:toggleScreens);
    }
  }
}