import 'package:admin_dashboard/screens/login_screen.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomSideMenu extends StatefulWidget {
  String initPageRoute;
  CustomSideMenu({
    required this.initPageRoute,
    super.key,
  });

  @override
  State<CustomSideMenu> createState() => _CustomSideMenuState();
}

class _CustomSideMenuState extends State<CustomSideMenu> {
  bool isMenuOpen = true;
  @override
  Widget build(BuildContext context) {
    SideMenuController sideMenuController = SideMenuController(initialPage: initPageSelector[widget.initPageRoute]);
    return SizedBox(
      width: 300,
      child: SideMenu(
        controller: sideMenuController,
        alwaysShowFooter: true,
        // showToggle: true,
        collapseWidth: 1000,
        // onDisplayModeChanged: (value) {
        //   switch (value) {
        //     case SideMenuDisplayMode.compact:
        //       isMenuOpen == false;
        //       break;
        //     case SideMenuDisplayMode.open:
        //       isMenuOpen == true;
        //       break;
        //     default:
        //   }
        // },
        displayModeToggleDuration: Duration(milliseconds: 500),
        style: SideMenuStyle(
          displayMode: SideMenuDisplayMode.open,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          hoverColor: const Color.fromARGB(33, 255, 86, 34),
          selectedColor: const Color.fromRGBO(255, 141, 107, 1),
          selectedTitleTextStyle: const TextStyle(color: Colors.white),
          selectedIconColor: Colors.white,
          showTooltip: true,
          // openSideMenuWidth: 300,
          // compactSideMenuWidth: 50,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 5.sp, color: const Color.fromARGB(131, 158, 158, 158), offset: const Offset(0, 3), spreadRadius: 2)],
          ),
        ),
        title: isMenuOpen == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 150,
                      width: 300,
                      alignment: Alignment.center,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Active Tech',
                            style: TextStyle(fontSize: 6.sp, color: const Color.fromRGBO(255, 141, 107, 1), fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                              text: '\nDashboard',
                              style: TextStyle(
                                fontSize: 5.sp,
                              )),
                        ]),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 4,
                    )
                  ],
                ),
              )
            : Text('its compact or auto'),
        footer: Padding(
          padding: EdgeInsets.all(1.9.sp),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(const Color.fromARGB(33, 255, 86, 34)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.sp),
                ),
              ),
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
              } on Exception catch (e) {
                print(e);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app_rounded,
                ),
                SizedBox(
                  width: 10,
                  height: 50,
                ),
                Text('Sign Out'),
              ],
            ),
          ),
        ),
        items: sideMenuItems(context),
      ),
    );
  }
}

Map initPageSelector = {
  '/dashboard': 0,
  '/products': 1,
  '/orders': 2,
  '/users': 3,
  '/settings': 4,
};

List<SideMenuItem> sideMenuItems(BuildContext context) {
  return [
    SideMenuItem(
      priority: initPageSelector['/dashboard'],
      title: 'Home',
      onTap: (p0, p1) {
        p1.changePage(p0);
        Navigator.of(context).pushReplacementNamed('/dashboard');
      },
      icon: const Icon(Icons.home_rounded),
    ),
    SideMenuItem(
      priority: initPageSelector['/products'],
      title: 'Products',
      onTap: (p0, p1) {
        p1.changePage(p0);
        // streamController.add(sideMenuItems.values.toList()[p0]);
        Navigator.pushReplacementNamed(context, '/products');
      },
      icon: const Icon(Icons.local_mall_rounded),
    ),
    SideMenuItem(
      priority: initPageSelector['/orders'],
      title: 'Orders',
      onTap: (p0, p1) {
        p1.changePage(p0);
        // streamController.add(sideMenuItems.values.toList()[p0]);
        Navigator.pushReplacementNamed(context, '/orders');
      },
      icon: const Icon(Icons.receipt_rounded),
    ),
    SideMenuItem(
      priority: initPageSelector['/users'],
      title: 'Users',
      onTap: (p0, p1) {
        p1.changePage(p0);
        // streamController.add(sideMenuItems.values.toList()[p0]);
        Navigator.pushReplacementNamed(context, '/users');
      },
      icon: const Icon(Icons.people_alt_rounded),
    ),
    SideMenuItem(
      priority: initPageSelector['/settings'],
      title: 'Settings',
      onTap: (p0, p1) {
        p1.changePage(p0);
        // streamController.add(sideMenuItems.values.toList()[p0]);
        Navigator.pushReplacementNamed(context, '/settings');
      },
      icon: const Icon(Icons.settings_rounded),
    ),
  ];
}
