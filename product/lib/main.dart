import 'package:flutter/material.dart';
import 'package:product/Page/AddProductPage.dart';
import 'package:product/Page/EditProductPage.dart';
import 'package:product/Page/home_admin.dart';

import 'package:product/Page/home_screen.dart';
import 'package:product/Page/login_screen.dart';
import 'package:product/Page/register.dart';
import 'package:product/providers/user_provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
          title: 'Login Example',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/home': (context) => HomeScreen(),
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterPage(),
            '/admin': (context) => HomeAdmin(),
            '/add_product': (context) => AddProductPage(),
          }),
    );
  }
}
