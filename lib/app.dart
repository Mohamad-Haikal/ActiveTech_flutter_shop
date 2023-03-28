import 'package:e_commerce_app_flutter/wrappers/authentification_wrapper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(title: appName, debugShowCheckedModeBanner: false, theme: theme(), home: AuthentificationWrapper()
            //home: AuthentificationWrapper(),
            );
      },
    );
  }
}
