import 'package:admin_dashboard/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:admin_dashboard/models/user_model.dart';

void showUserDetails(context, String uid, String userName) async {
  User user = await Provider.of<UsersProvider>(context, listen: false).getUser(uid: uid) ??
      User(displayPicture: '', email: '', name: '', phoneNumber: '', uid: '');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('User Details')),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 150, height: 150, child: ClipRRect(borderRadius: BorderRadius.circular(10.sp), child: Image.network(user.displayPicture))),
            Padding(
              padding: EdgeInsets.all(4.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Customer Name: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: user.name == '' ? userName : user.name,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Phone Number: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${user.phoneNumber}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Email: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${user.email}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'User ID: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${user.uid}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancle'),
          ),
        ],
      );
    },
  );
}
