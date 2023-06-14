import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:admin_dashboard/widgets/custom_app_bar.dart';
import 'package:admin_dashboard/widgets/custom_side_menu.dart';
import 'package:admin_dashboard/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        body: Row(
          children: [
            CustomSideMenu(initPageRoute: SettingsScreen.route),
            Expanded(
              child: Column(
                children: [
                  CustomAppBar(
                    titleWidget: 'Settings',
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return SizedBox();
    }
  }
}
