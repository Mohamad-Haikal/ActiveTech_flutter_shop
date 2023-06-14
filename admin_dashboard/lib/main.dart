import 'package:admin_dashboard/providers/users_provider.dart';
import 'package:admin_dashboard/screens/orders_screen.dart';
import 'package:admin_dashboard/screens/products_screen.dart';
import 'package:admin_dashboard/screens/settings_screen.dart';
import 'package:admin_dashboard/screens/users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:admin_dashboard/providers/orders_provider.dart';
import 'package:admin_dashboard/providers/products_provider.dart';
import 'package:admin_dashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:admin_dashboard/screens/login_screen.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:admin_dashboard/constants.dart';
import 'package:sizer/sizer.dart';

//FIXME: اصلاح مشكلة عندما اضغط زر العودة في المتصفح لا يرجع الى مسار الصفحة السابقة
//TODO: عمل جرادينت للتصميم
void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDktg2_URSmtv4ILvFsYkOG2Pdaq0Wz3bU",
    authDomain: "firstflutterapp-9b91a.firebaseapp.com",
    databaseURL: "https://firstflutterapp-9b91a-default-rtdb.firebaseio.com",
    projectId: "firstflutterapp-9b91a",
    storageBucket: "firstflutterapp-9b91a.appspot.com",
    messagingSenderId: "253307138634",
    appId: "1:253307138634:web:e219b5729780ce69a6ecb3",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    print('currentUser: $currentUser');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsersProvider()),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: ThemeData(
              primarySwatch: Colors.deepOrange,
              fontFamily: 'cairo',
              scaffoldBackgroundColor: kPrimaryLightColor,
            ),
            initialRoute: currentUser != null ? DashboardScreen.route : LoginScreen.route,
            routes: {
              DashboardScreen.route: (context) => DashboardScreen(),
              LoginScreen.route: (context) => LoginScreen(),
              UsersScreen.route: (context) => UsersScreen(),
              SettingsScreen.route: (context) => SettingsScreen(),
              ProductsScreen.route: (context) => ProductsScreen(),
              OrdersScreen.route: (context) => OrdersScreen(),
            },
          );
        },
      ),
    );
  }
}
