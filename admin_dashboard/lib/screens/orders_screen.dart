import 'package:admin_dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<QueryDocumentSnapshot> _orders = [];

  @override
  void initState() {
    super.initState();
    _getOrders();
  }

  Future<void> _getOrders() async {
    final orders = await FirebaseFirestore.instance.collection('orders').get();
    // FirebaseFirestore.instance.collection('orders').add(orders.docs[0].data());
    setState(() {
      _orders = orders.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: _orders.isNotEmpty
          ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ExpansionPanelList.radio(
                initialOpenPanelValue: null,
                animationDuration: const Duration(milliseconds: 500),
                children: List.generate(_orders.length, (index) {
                  final order = _orders[index];
                  final personelInformation = order['personelInformation'] as Map;
                  final orderItems = order['orderItems'] as List;

                  // إنشاء قائمة للعناصر المرتبطة بالطلب
                  final itemsList = ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = orderItems[index];
                      return ListTile(
                        title: Text(item['name'] ?? ''),
                        subtitle: Text(item['description'] ?? ''),
                        trailing: Text(item['price']?.toString() ?? ''),
                      );
                    },
                  );
                  // إنشاء العنصر الرئيسي للطلب ومعلومات المنتجات المرتبطة به
                  return ExpansionPanelRadio(
                    headerBuilder: (context, isExpanded) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order['orderId']}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    order['status'] ?? '',
                                    style: TextStyle(
                                        color: order['status'] == 'completed'
                                            ? Colors.green
                                            : order['status'] == 'waiting'
                                                ? Colors.orange
                                                : order['status'] == 'shipping'
                                                    ? Colors.blue
                                                    : order['status'] == 'cancelled'
                                                        ? Colors.red
                                                        : Colors.black),
                                  )
                                ],
                              ),
                            ),
                            Text(order['totalprice']?.toString() ?? '')
                          ],
                        ),
                      );
                    },
                    value: index,
                    canTapOnHeader: true,
                    body: Column(
                      children: [
                        itemsList, // قائمة المنتجات المرتبطة بالطلب
                      ],
                    ),
                  );
                }),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
