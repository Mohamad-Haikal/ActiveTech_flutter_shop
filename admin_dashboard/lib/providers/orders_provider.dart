import 'package:admin_dashboard/models/order_model.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';

class OrdersProvider extends ChangeNotifier {
  List<model.Order> _items = [];

  List<model.Order> get items {
    return [..._items];
  }

  Future getOrders() async {
    final List<model.Order> loadedOrders = [];
    try {
      await FirebaseFirestore.instance.collection('orders').get().then(
        (QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final model.Order order = model.Order.fromMap(doc.data() as Map<String, dynamic>);
            loadedOrders.add(order);
          }
        },
      );
      _items = loadedOrders;
      notifyListeners();
    } catch (error) {
      print('========================== error is: $error');
      rethrow;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    model.Order? order;
    try {
      await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).get().then(
        (QuerySnapshot querySnapshot) {
          order = model.Order.fromMap((querySnapshot.docs as QueryDocumentSnapshot).data() as Map<String, dynamic>);
          pprint(order);
          return order;
        },
      );
      notifyListeners();
      return null;
    } catch (error) {
      print('========================== error is: $error');
      return null;

    }
  }
}
