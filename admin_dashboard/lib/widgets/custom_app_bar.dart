import 'package:admin_dashboard/constants.dart';
import 'package:admin_dashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:admin_dashboard/screens/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleWidget;
  const CustomAppBar({Key? key, required this.titleWidget}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    Reference ref = FirebaseStorage.instance.ref();
    showAccountMenu() {
      showMenu(
        context: context,
        position: RelativeRect.fromDirectional(
            textDirection: TextDirection.rtl, start: 10, top: 56, end: MediaQuery.of(context).size.width, bottom: MediaQuery.of(context).size.height),
        items: [
          PopupMenuItem(
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
              } on Exception catch (e) {
                print(e);
              }
            },
            value: '/signOut',
            child: Row(
              children: [
                const Icon(
                  Icons.exit_to_app_rounded,
                  color: kPrimaryColor,
                ),
                const SizedBox(
                  width: 10,
                  height: 50,
                ),
                Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 3.sp),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      alignment: Alignment.centerLeft,
      color: const Color.fromARGB(255, 255, 255, 255),
      // we can set width here with conditions
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Positioned(
          //   left: 0,
          //   child: Builder(
          //     builder: (context) => IconButton(
          //       icon: Icon(Icons.menu),
          //       onPressed: () {
          //         Scaffold.of(context).openDrawer();
          //       },
          //     ),
          //   ),
          // ),
          Positioned(
            left: 0.w,
            child: Text(
              titleWidget,
              style: TextStyle(color: const Color.fromRGBO(255, 141, 107, 1), fontWeight: FontWeight.w600, fontSize: 5.sp),
            ),
          ),
          Positioned(
            right: 0.w,
            child: InkWell(
              onTap: () {
                showAccountMenu();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryColor, width: 4),
                  borderRadius: BorderRadius.circular(25.sp),
                ),
                //FIXME(✅): اصلاح عدم اظهار صورة الحساب
                child: FutureBuilder(
                  future: currentUser != null ? ref.child('user/display_picture/${currentUser.uid}').getDownloadURL() : Future(() => ''),
                  builder: (context, snapshot) {
                    String? imageUrl = snapshot.data;
                    pprint(imageUrl);
                    if (imageUrl == null || imageUrl == '') {
                      return const Center(
                        child: Icon(
                          Icons.person,
                          size: 25,
                          color: kPrimaryColor,
                        ),
                      );
                    }
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.sp),
                        child: Image.network(
                          imageUrl,
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 3.5.w,
            child: Row(
              children: [
                const Text(
                  'Hello ',
                  style: TextStyle(fontWeight: FontWeight.w500, color: kTextColor),
                ),
                Text(
                  '${currentUser?.displayName ?? 'Admin'} !',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///width doesnt matter
  @override
  Size get preferredSize => const Size(200, kToolbarHeight);
}
