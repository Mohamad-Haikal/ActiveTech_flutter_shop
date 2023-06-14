import 'package:admin_dashboard/providers/orders_provider.dart';
import 'package:admin_dashboard/providers/products_provider.dart';
import 'package:admin_dashboard/screens/dashboard_screen/components/orders_table_card.dart';
import 'package:admin_dashboard/screens/dashboard_screen/components/show_user_dialog.dart';
import 'package:admin_dashboard/screens/login_screen.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:admin_dashboard/models/user_model.dart' as userModel;
import 'package:admin_dashboard/constants.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:admin_dashboard/models/product_model.dart';
import 'package:admin_dashboard/models/order_model.dart' as orderModel;
import 'package:admin_dashboard/providers/users_provider.dart';
import 'package:admin_dashboard/widgets/custom_app_bar.dart';
import 'package:admin_dashboard/widgets/custom_side_menu.dart';
import 'package:admin_dashboard/screens/settings_screen.dart';

class OrdersScreen extends StatefulWidget {
  static const String route = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrdersProvider>(context, listen: false).getOrders();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        body: Row(
          children: [
            CustomSideMenu(initPageRoute: OrdersScreen.route),
            Expanded(
              child: Column(
                children: [
                  const CustomAppBar(
                    titleWidget: 'Orders',
                  ),
                  Expanded(
                    child: OrdersTableCard(),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return const SizedBox();
    }
  }

  DataRow2 ordersListItem(orderModel.Order order) {
    return DataRow2(
      cells: [
        DataCell(
          Text(order.orderId),
        ),
        DataCell(
          TextButton(
              onPressed: () {
                showUserDetails(context, order.uId, order.personalInformation['name']);
              },
              child: Text('${order.personalInformation['name']}')),
        ),
        DataCell(
          Text(
            getOrderStatusText(order.status),
            style: TextStyle(color: getOrderStatusColor(order.status)),
          ),
        ),
        DataCell(
          Row(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  showOrderDetails(context, order);
                },
                icon: const Icon(Icons.visibility_rounded),
                tooltip: 'View Details',
                splashRadius: 3.sp,
                color: const Color.fromRGBO(255, 141, 107, 1),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.pending_rounded,
                color: Color.fromRGBO(255, 141, 107, 1),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

void showProductDetails(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('Order Details')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Customer Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: product.name,
                    style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: '${product.price} JOD',
                    style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            // RichText(
            //   text: TextSpan(
            //     children: [
            //       TextSpan(
            //         text: 'rate: ',
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            //       ),
            //       TextSpan(
            //         text: '${getOrderStatusText(product.)}',
            //         style: TextStyle(fontSize: 16, color: getOrderStatusColor(product.status)),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 8),
            // RichText(
            //   text: TextSpan(
            //     children: [
            //       TextSpan(
            //         text: 'Date: ',
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            //       ),
            //       TextSpan(
            //         text: '${DateFormat('yyyy-MM-dd HH:mm').format(product.orderDate.toDate())}',
            //         style: TextStyle(fontSize: 16, color: Colors.black),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 8),
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

void showOrderDetails(BuildContext context, orderModel.Order order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('Order Details')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Customer Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    showUserDetails(context, order.uId, order.personalInformation['name']);
                  },
                  child: Text('${order.personalInformation['name']}', style: const TextStyle(fontSize: 16, color: kPrimaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: '${order.totalPrice} JOD',
                    style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            Column(
              children: productsList(context, order.orderItems),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: getOrderStatusText(order.status),
                    style: TextStyle(fontSize: 16, color: getOrderStatusColor(order.status)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Date: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate.toDate()),
                    style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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

List<Widget> productsList(context, List products) {
  // pprint(products, DebugType.response);
  List<Widget> productItemList = List.generate(
      products.length,
      (index) => FutureBuilder(
          future: Provider.of<ProductsProvider>(context, listen: false).findById(products[index]['productId']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Product product = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: Colors.white,
                  hoverColor: kPrimaryLightColor,
                  enabled: true,
                  leading: Image.network(product.images[0]),
                  title: Text(product.name),
                  subtitle: Text(product.description, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    double.parse('${product.price}').toStringAsFixed(2).toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: Colors.white,
                  hoverColor: kPrimaryLightColor,
                  enabled: true,
                  leading: Container(
                    color: Colors.black26,
                    width: 35,
                    height: 35,
                  ),
                  title: Text(products[index]['name'] ?? ''),
                  subtitle: Text(products[index]['description'] ?? ''),
                  trailing: Text(
                    double.parse(products[index]['price']).toStringAsFixed(2).toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }
          }));
  // List<Widget> productItemList = List.generate(
  //   products.length,
  //   (index) => Padding(
  //     padding: const EdgeInsets.only(bottom: 6.0),
  //     child: ListTile(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       tileColor: Colors.white,
  //       hoverColor: kPrimaryLightColor,
  //       enabled: true,
  //       // leading: Image.network(products[index]['images'][0] ?? ''),
  //       title: Text(products[index]['name']),
  //       subtitle: Text(products[index]['description']),
  //       trailing: Text(
  //       double.parse('${products[index]['price']}').toStringAsFixed(2).toString(),
  //       style: TextStyle(fontSize: 18),
  //       ),
  //     ),
  //   ),
  // );
  // pprint('productsList before return');
  return productItemList;
}

String getOrderStatusText(int status) {
  switch (status) {
    case 0:
      return 'Pending'; // Pending - 0: The order has been received and is awaiting processing or confirmation.
    case 1:
      return 'Processing'; // Processing - 1: The seller or the e-commerce platform is actively working on fulfilling the order.
    case 2:
      return 'Out for Delivery'; // Out for Delivery - 2: The order has reached the local carrier or delivery service and is currently en route to the customer's specified delivery address.
    case 3:
      return 'Delivered'; // Delivered - 3: The order has been successfully delivered to the customer's address and received by them or an authorized recipient.
    case 4:
      return 'Cancelled'; // Cancelled - 4: The order has been canceled either by the customer, the seller, or due to unforeseen circumstances.
    default:
      return 'Unknown';
  }
}

Color getOrderStatusColor(int status) {
  switch (status) {
    case 0:
      return Colors.orange; // Pending - 0: The order has been received and is awaiting processing or confirmation.
    case 1:
      return Colors.blue; // Processing - 1: The seller or the e-commerce platform is actively working on fulfilling the order.
    case 2:
      return Colors
          .indigo; // Out for Delivery - 2: The order has reached the local carrier or delivery service and is currently en route to the customer's specified delivery address.
    case 3:
      return Colors
          .green; // Delivered - 3: The order has been successfully delivered to the customer's address and received by them or an authorized recipient.
    case 4:
      return Colors
          .red; // Cancelled - 4: The order has been canceled either by the customer, the seller, or due to unforeseen circumstances. The cancellation may be initiated before or after the shipment has taken place.
    default:
      return Colors.grey;
  }
}
