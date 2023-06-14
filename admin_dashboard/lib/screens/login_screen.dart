import 'package:admin_dashboard/constants.dart';
import 'package:admin_dashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:admin_dashboard/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:admin_dashboard/providers/users_provider.dart';

class LoginScreen extends StatefulWidget {
  static const String route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailCTRL = TextEditingController();
    TextEditingController passwordCTRL = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    print(FirebaseAuth.instance.currentUser);
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Card(
            elevation: 15,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.sp)),
            child: SizedBox(
              height: 60.h,
              width: 26.w,
              // child: Stack(
              //   children: [
              //     Positioned(
              //       top: 30.0,
              //       left: 0.0,
              //       right: 0.0,
              //       child: Text(
              //         'Login',
              //         style: TextStyle(fontSize: 10.sp, color: kPrimaryColor, fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //     Positioned(
              //       top: 80.0,
              //       left: 0.0,
              //       right: 0.0,
              //       child: Text(
              //         'Welcome To Dashboard',
              //         style: TextStyle(fontSize: 4.sp, color: kTextColor, fontWeight: FontWeight.w600),
              //       ),
              //     ),
              //     Positioned(
              //       top: 120.0,
              //       left: 0.0,
              //       right: 0.0,
              //       child: SizedBox(
              //         height: 60.h,
              //         width: 26.w,
              //         child: Column(
              //           children: [
              //             Expanded(
              //               child: Padding(
              //                 padding: EdgeInsets.symmetric(horizontal: 6.w),
              //                 child: Form(
              //                   key: _formKey,
              //                   onChanged: () {
              //                     // _formKey.currentState?.validate();
              //                   },
              //                   child: Column(
              //                     mainAxisAlignment: MainAxisAlignment.center,
              //                     crossAxisAlignment: CrossAxisAlignment.center,
              //                     children: [
              //                       TextFormField(
              //                         controller: emailCTRL,
              //                         validator: (value) {
              //                           // validation logic
              //                         },
              //                         onChanged: (value) {
              //                           // onChanged logic
              //                         },
              //                         onFieldSubmitted: (value) {
              //                           // onFieldSubmitted logic
              //                         },
              //                         textAlignVertical: TextAlignVertical.center,
              //                         decoration: InputDecoration(
              //                             // decoration properties
              //                             ),
              //                       ),
              //                       SizedBox(
              //                         height: 2.h,
              //                       ),
              //                       TextFormField(
              //                         controller: passwordCTRL,
              //                         obscureText: true,
              //                         validator: (value) {
              //                           // validation logic
              //                         },
              //                         onChanged: (value) {
              //                           // onChanged logic
              //                         },
              //                         textAlignVertical: TextAlignVertical.center,
              //                         decoration: InputDecoration(
              //                             // decoration properties
              //                             ),
              //                       ),
              //                       SizedBox(
              //                         height: 3.h,
              //                       ),
              //                       LoadingButton(
              //                         defaultWidget: Text(''),
              //                         onPressed: () {
              //                           return Future(() => null);
              //                         },
              //                         // button properties
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              child: Stack(
                children: [
                  Positioned(
                    top: 1.h,
                    left: 0.0,
                    right: 0.0,
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 10.sp, color: kPrimaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 13.h,
                    left: 0.0,
                    right: 0.0,
                    child: Center(
                      child: Text(
                        'Welcome To  Dashboard',
                        style: TextStyle(fontSize: 4.sp, color: kTextColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7.h,
                    left: 0.0,
                    right: 0.0,
                    child: SizedBox(
                      height: 60.h,
                      width: 26.w,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Form(
                                key: _formKey,
                                onChanged: () {
                                  // _formKey.currentState?.validate();
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextFormField(
                                      controller: emailCTRL,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter an email address';
                                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) => value = value.trim(),
                                      onFieldSubmitted: (value) => _formKey.currentState?.validate(),
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                          hintText: 'Email',
                                          isDense: true,
                                          alignLabelWithHint: true,
                                          errorMaxLines: null,
                                          floatingLabelAlignment: FloatingLabelAlignment.center,
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          // constraints: BoxConstraints.expand(width: 16.w, height: 7.h),
                                          hintMaxLines: 1,
                                          labelStyle: TextStyle(fontSize: 2.sp),
                                          floatingLabelStyle: TextStyle(fontSize: 2.sp),
                                          hintStyle: TextStyle(fontSize: 3.5.sp),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.sp),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    TextFormField(
                                      controller: passwordCTRL,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a password';
                                        } else if (value.length < 6) {
                                          return 'Password must be at least 6 characters long';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) => value = value.trim(),
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        errorMaxLines: null,
                                        // constraints: BoxConstraints(minHeight: double.infinity),
                                        // constraints: BoxConstraints.expand(width: 16.w, height: 7.h),
                                        hintText: 'Password',
                                        alignLabelWithHint: true,
                                        hintMaxLines: 1,
                                        floatingLabelAlignment: FloatingLabelAlignment.center,
                                        isDense: true,
                                        labelStyle: TextStyle(fontSize: 2.sp),
                                        hintStyle: TextStyle(fontSize: 3.5.sp),
                                        floatingLabelStyle: TextStyle(fontSize: 2.sp),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.sp),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    LoadingButton(
                                      defaultWidget: Center(
                                          child: Text(
                                        'Login',
                                        style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5, fontSize: 4.sp),
                                      )),
                                      color: kPrimaryColor,
                                      borderRadius: 25,
                                      animate: true,
                                      loadingWidget: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          color: Colors.white,
                                        )),
                                      ),
                                      onPressed: () async {
                                        // await Future.delayed(const Duration(seconds: 2));
                                        if (_formKey.currentState!.validate()) {
                                          await Authentication.signIn(email: emailCTRL.text, password: passwordCTRL.text)
                                              .then((value) => print(value?.user))
                                              .onError((error, stackTrace) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error: $error')));
                                          });
                                          User? currentUser = FirebaseAuth.instance.currentUser;
                                          if (currentUser != null) {
                                            String? role = await Provider.of<UsersProvider>(context, listen: false).getRole(uid: currentUser.uid);
                                            if (role == 'admin') {
                                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                builder: (context) {
                                                  return const DashboardScreen();
                                                },
                                              ));
                                            } else {
                                              FirebaseAuth.instance.signOut();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('You are not an admin'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } else {}
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(DashboardScreen.route, (route) => false);
      return const SizedBox();
    }
  }
}
