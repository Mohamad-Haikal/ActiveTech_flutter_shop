import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final List orderItems;
  final Timestamp orderDate;
  final Map personalInformation;
  final Map shippingAddress;
  final int status;
  final String totalPrice;
  final String uId;

  Order({
    required this.orderId,
    required this.orderItems,
    required this.orderDate,
    required this.personalInformation,
    required this.shippingAddress,
    required this.status,
    required this.totalPrice,
    required this.uId,
  });

  factory Order.fromMap(Map<String, dynamic> data,) {
    return Order(
      orderId: data['orderId'] ?? '',
      orderItems: data['orderItems'] ?? [''],
      orderDate: data['orderdate'] ?? '',
      personalInformation: data['personelInformation'] ?? {'': ''},
      shippingAddress: data['shippingAddress'] ?? {'': ''},
      status: int.parse('${data['status'] ?? 5}'),
      totalPrice: data['totalprice'] ?? '',
      uId: data['uId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderItems': orderItems,
      'orderdate': orderDate,
      'personelInformation': personalInformation,
      'shippingAddress': shippingAddress,
      'status': status,
      'totalPrice': totalPrice,
      'uId': uId,
    };
  }
}
