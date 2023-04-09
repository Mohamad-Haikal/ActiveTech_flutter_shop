import 'package:admin_dashboard/screens/orders_screen.dart';
import 'package:admin_dashboard/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDktg2_URSmtv4ILvFsYkOG2Pdaq0Wz3bU",
          authDomain: "firstflutterapp-9b91a.firebaseapp.com",
          databaseURL: "https://firstflutterapp-9b91a-default-rtdb.firebaseio.com",
          projectId: "firstflutterapp-9b91a",
          storageBucket: "firstflutterapp-9b91a.appspot.com",
          messagingSenderId: "253307138634",
          appId: "1:253307138634:web:e219b5729780ce69a6ecb3"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My E-commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        OrdersScreen.routeName: (ctx) => OrdersScreen(),
        ProductsScreen.routeName: (ctx) => ProductsScreen(),
      },
    );
  }
}
