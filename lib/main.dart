import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = "pk_test_51MiOFqCca33SRveIuZm72WKFdLGpiCkhd1pSQmEwoG4Xx77er6L9PzylrmpF6FjyymyG6kdcHJk65Q2w3TUjHvLn00CGSDcEvI";

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterNativeSplash.removeAfter(initialization);
  runApp(App());
}


Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 3));
}