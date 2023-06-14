import 'package:admin_dashboard/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';

class UsersProvider with ChangeNotifier {
  List<User> _items = [];

  List<User> get items {
    return [..._items];
  }

  Future getUsers() async {
    final List<User> loadedUsers = [];
    try {
      await FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final User user = User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          loadedUsers.add(user);
        }
      });
      _items = loadedUsers;
      notifyListeners();
    } catch (error) {
      print('error : $error');
      rethrow;
    }
  }

  Future<String?> getRole({required String uid}) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      return snapshot.data()?['role'] as String?;
    } else {
      return null;
    }
  }

  Future<User?> getUser({required String uid}) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String,dynamic>? user = snapshot.data()??{};
    if (snapshot.exists && user != null) {
      return User.fromMap(user, uid);
    } else {
      return null;
    }
  }
}
