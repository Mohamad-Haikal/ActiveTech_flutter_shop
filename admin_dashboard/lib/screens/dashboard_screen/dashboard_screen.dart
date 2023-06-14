// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:admin_dashboard/screens/dashboard_screen/components/orders_table_card.dart';
import 'package:admin_dashboard/screens/dashboard_screen/components/show_user_dialog.dart';
import 'package:admin_dashboard/widgets/dashboard_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:admin_dashboard/constants.dart';
import 'package:admin_dashboard/models/order_model.dart';
import 'package:admin_dashboard/models/product_model.dart';
import 'package:admin_dashboard/models/user_model.dart' as user_model;
import 'package:admin_dashboard/providers/orders_provider.dart';
import 'package:admin_dashboard/providers/products_provider.dart';
import 'package:admin_dashboard/providers/users_provider.dart';
import 'package:admin_dashboard/widgets/custom_app_bar.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:admin_dashboard/widgets/custom_side_menu.dart';
import 'package:admin_dashboard/widgets/dashboard_titled_card.dart';
import 'package:admin_dashboard/screens/login_screen.dart';
import 'package:admin_dashboard/screens/orders_screen.dart';
import 'package:admin_dashboard/screens/products_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String route = '/dashboard';
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    double salesCount = 0;
    String calcSalesCount() {
      for (var order in Provider.of<OrdersProvider>(context, listen: false).items) {
        salesCount += double.parse(order.totalPrice.toString());
      }
      return '$salesCount';
    }
    // double crossAxisCount = 0;
    // final double screenWidthSize = MediaQuery.of(context).size.width;
    // if (screenWidthSize > 1080) {
    //   crossAxisCount = 3;
    // } else if (screenWidthSize > 720) {
    //   crossAxisCount = 2;
    // } else if (screenWidthSize > 620) {
    //   crossAxisCount = 1;
    // } else {
    //   crossAxisCount = 1;
    // }

    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Row(
          children: [
            Center(child: CustomSideMenu(initPageRoute: DashboardScreen.route)),
            Flexible(
              child: Column(
                children: [
                  CustomAppBar(
                    titleWidget: 'Dashboard',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(double.infinity, 150.h)),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    DashboardCard(
                                      title: 'Total Orders',
                                      body: Row(
                                        children: [
                                          Icon(Icons.receipt, size: 10.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                          FutureBuilder(
                                            future: Provider.of<OrdersProvider>(context, listen: false).getOrders(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.done) {
                                                return Text(
                                                  Provider.of<OrdersProvider>(context, listen: false).items.length.toString(),
                                                  style: TextStyle(fontSize: 6.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                                );
                                              }
                                              return Center(child: CircularProgressIndicator());
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    DashboardCard(
                                      title: 'Total Products',
                                      body: Center(
                                        child: Row(
                                          children: [
                                            Icon(Icons.local_mall, size: 10.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                            FutureBuilder(
                                              future: Provider.of<ProductsProvider>(context, listen: false).getProducts(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.done) {
                                                  return Text(
                                                    Provider.of<ProductsProvider>(context, listen: false).items.length.toString(),
                                                    style: TextStyle(fontSize: 6.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                                  );
                                                }
                                                return Center(child: CircularProgressIndicator());
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DashboardCard(
                                      title: 'Total Sales',
                                      body: Center(
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_money_rounded, size: 10.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                            FutureBuilder(
                                                future: Provider.of<OrdersProvider>(context, listen: false).getOrders(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.done) {
                                                    return Text(
                                                      calcSalesCount(),
                                                      style: TextStyle(fontSize: 6.sp, color: Color.fromRGBO(255, 141, 107, 1)),
                                                    );
                                                  }
                                                  return Center(child: CircularProgressIndicator());
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DashboardCard(
                                      title: 'Total Users',
                                      body: Center(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.people_rounded,
                                                size: 10.sp,
                                                color: Color.fromRGBO(255, 141, 107, 1),
                                              ),
                                            ),
                                            FutureBuilder(
                                              future: Provider.of<UsersProvider>(context, listen: false).getUsers(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.done) {
                                                  return Text(
                                                    Provider.of<UsersProvider>(context, listen: false).items.length.toString(),
                                                    style: TextStyle(
                                                      fontSize: 6.sp,
                                                      color: Color.fromRGBO(255, 141, 107, 1),
                                                    ),
                                                  );
                                                }
                                                return Center(child: CircularProgressIndicator());
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    OrdersTableCard(header: 'Latest Orders'),
                                    DashboardTitledCard(
                                      flex: 4,
                                      header: 'List Of Products',
                                      pageRoute: ProductsScreen.route,
                                      body: FutureBuilder(
                                        future: Provider.of<ProductsProvider>(context, listen: false).getProducts(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            return DataTable2(
                                              empty: Text('none'),
                                              showBottomBorder: true,
                                              headingTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Color.fromARGB(183, 0, 0, 0)),
                                              bottomMargin: 2.h,
                                              columns: [
                                                DataColumn2(
                                                  label: Text('Id'),
                                                ),
                                                DataColumn2(
                                                  label: Text('Title'),
                                                ),
                                                DataColumn2(
                                                  label: Text('Price'),
                                                ),
                                                DataColumn2(
                                                  size: ColumnSize.S,
                                                  label: Text('Type'),
                                                ),
                                                // DataColumn2(
                                                //   size: ColumnSize.S,
                                                //   label: Text('rate'),
                                                // ),
                                              ],
                                              rows: List.generate(
                                                Provider.of<ProductsProvider>(context, listen: false).items.length,
                                                (index) {
                                                  return DashboardCRUD.productsDataItems(
                                                      Provider.of<ProductsProvider>(context, listen: false).items[index]);
                                                },
                                              ),
                                            );
                                          }
                                          return Center(child: CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return SizedBox();
    }
  }
}

class DashboardCRUD {
  static DataRow2 ordersDataItems(BuildContext context, Order order) {
    GlobalKey buttonKey = GlobalKey(debugLabel: 'orderStateButton${order.orderId}');
    int orderStatus = order.status;
    return DataRow2(
      onTap: () {
        DashboardCRUD.showOrderDetails(context, order);
      },
      cells: [
        DataCell(
          Text('${order.orderId}'),
        ),
        DataCell(
          TextButton(
            onPressed: () {
              showUserDetails(context, order.uId, order.personalInformation['name']);
            },
            child: Text(
              '${order.personalInformation['name']}',
            ),
          ),
        ),
        DataCell(
          StatefulBuilder(
            builder: (context, setState) {
              return TextButton(
                key: buttonKey,
                onPressed: () {
                  RenderBox buttonRenderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
                  Offset buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
                  showMenu(
                    context: context,
                    position: RelativeRect.fromDirectional(
                        textDirection: TextDirection.ltr,
                        start: buttonPosition.dx,
                        top: buttonPosition.dy + 10,
                        end: MediaQuery.of(context).size.width - buttonPosition.dx,
                        bottom: MediaQuery.of(context).size.height - buttonPosition.dy),
                    items: List.generate(
                      5,
                      (index) => PopupMenuItem(
                        onTap: () async {
                          await DashboardCRUD.updateOrderState(order.orderId, index).then((value) => {
                                if (value != null)
                                  {
                                    setState(
                                      () {
                                        orderStatus = index;
                                        pprint('setStated');
                                      },
                                    ),
                                    pprint(value)
                                  }
                                else
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('failed to update order state'),
                                      ),
                                    ),
                                  }
                              });
                        },
                        value: '/${getOrderStatusText(index)}',
                        child: Text(
                          getOrderStatusText(index),
                          style: TextStyle(color: getOrderStatusColor(index)),
                        ),
                      ),
                    ),
                  );
                  pprint(orderStatus);
                },
                child: Text(
                  getOrderStatusText(orderStatus),
                  style: TextStyle(color: getOrderStatusColor(orderStatus)),
                ),
              );
            },
          ),
        ),
        DataCell(
          Row(mainAxisSize: MainAxisSize.min, children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: IconButton(
            //     onPressed: () {
            //       showOrderDetails(context, order);
            //     },
            //     icon: Icon(Icons.visibility_rounded),
            //     tooltip: 'View Details',
            //     splashRadius: 3.sp,
            //     color: Color.fromRGBO(255, 141, 107, 1),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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

  static DataRow2 productsDataItems(Product product) {
    return DataRow2(
      cells: [
        DataCell(
          Text('${product.id}'),
        ),
        DataCell(
          Text('${product.name}'),
        ),
        DataCell(
          Text('${product.price}'),
        ),
        DataCell(
          Text('${product.images}'),
        ),
        // DataCell(
        //   Text(
        //     getOrderStatusText(product.rate),
        //     style: TextStyle(color: getOrderStatusColor(product.rate)),
        //   ),
        // ),
        // DataCell(
        //   Row(mainAxisSize: MainAxisSize.min, children: [
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: IconButton(
        //         onPressed: () {
        //           showProductDetails(context, product);
        //         },
        //         icon: Icon(Icons.visibility_rounded),
        //         tooltip: 'View Details',
        //         splashRadius: 3.sp,
        //         color: Color.fromRGBO(255, 141, 107, 1),
        //       ),
        //     ),
        //     // Padding(
        //     //   padding: const EdgeInsets.all(8.0),
        //     //   child: Icon(
        //     //     Icons.pending_rounded,
        //     //     color: Color.fromRGBO(255, 141, 107, 1),
        //     //   ),
        //     // ),
        //   ]),
        // ),
      ],
    );
  }

  static Future<int?> updateOrderState(String orderId, int orderState) async {
    String? docId;
    await cf.FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).get().then(
          (snapshot) => snapshot.docs.forEach(
            (doc) {
              docId = doc.id;
            },
          ),
        );
    if (docId != null) {
      cf.FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': orderState});
    }
    int? docid;
    return cf.FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).get().then(
      (snapshot) {
        snapshot.docs.forEach(
          (doc) {
            docid = (doc.data()['orderId'] as int);
          },
        );
        return docid;
      },
    );
  }

  static void showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Order Details')),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Customer Name: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text: '${product.name}',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Amount: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text: '${product.price} JOD',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Products:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 8),
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
              SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancle'),
            ),
          ],
        );
      },
    );
  }

  static void showOrderDetails(BuildContext context, Order order) {
    GlobalKey buttonKey = GlobalKey(debugLabel: 'textbutton+${order.orderId}');
    Order? newOrder = order;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Order Details')),
          content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Text(
                  'Customer Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    showUserDetails(context, order.uId, order.personalInformation['name']);
                  },
                  child: Text('${order.personalInformation['name']}', style: TextStyle(fontSize: 16, color: kPrimaryColor)),
                ),
              ],
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: '${order.totalPrice} JOD',
                    style: TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            Column(
              children: productsList(context, order.orderItems),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextButton(
                      key: buttonKey,
                      onPressed: () {
                        RenderBox buttonRenderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
                        Offset buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
                        showMenu(
                          context: context,
                          position: RelativeRect.fromDirectional(
                              textDirection: TextDirection.ltr,
                              start: buttonPosition.dx,
                              top: buttonPosition.dy + 10,
                              end: MediaQuery.of(context).size.width - buttonPosition.dx,
                              bottom: MediaQuery.of(context).size.height - buttonPosition.dy),
                          items: List.generate(
                            5,
                            (index) => PopupMenuItem(
                              onTap: () async {
                                await DashboardCRUD.updateOrderState(order.orderId, index).then((value) => {
                                      if (value != null)
                                        {
                                          Provider.of<OrdersProvider>(context, listen: false)
                                              .getOrderById(order.orderId)
                                              .then((value) => {newOrder = value as Order?}),
                                          setState(
                                            () {
                                              pprint('setStated');
                                            },
                                          ),
                                          pprint(value)
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('failed to update order state'),
                                            ),
                                          ),
                                        }
                                    });
                              },
                              value: '/${getOrderStatusText(index)}',
                              child: Text(
                                getOrderStatusText(index),
                                style: TextStyle(color: getOrderStatusColor(index)),
                              ),
                            ),
                          ),
                        );
                        pprint('${newOrder?.status}');
                      },
                      child: Text(
                        getOrderStatusText(newOrder?.status ?? 10),
                        style: TextStyle(color: getOrderStatusColor(newOrder?.status ?? 10)),
                      ),
                    );
                  },
                )
              ],
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Date: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  TextSpan(
                    text: '${intl.DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate.toDate())}',
                    style: TextStyle(fontSize: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancle'),
            ),
          ],
        );
      },
    );
  }

  static List<Widget> productsList(context, List products) {
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
                      style: TextStyle(fontSize: 18),
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
                      style: TextStyle(fontSize: 18),
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

  static void showUserDetails(context, String uid, String userName) async {
    user_model.User user = await Provider.of<UsersProvider>(context, listen: false).getUser(uid: uid) ??
        user_model.User(displayPicture: '', email: '', name: '', phoneNumber: '', uid: '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('User Details')),
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
                          TextSpan(
                            text: 'Customer Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          TextSpan(
                            text: user.name == '' ? userName : user.name,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Phone Number: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          TextSpan(
                            text: '${user.phoneNumber}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Email: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          TextSpan(
                            text: '${user.email}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'User ID: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          TextSpan(
                            text: '${user.uid}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
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
              child: Text('Cancle'),
            ),
          ],
        );
      },
    );
  }

  static String getOrderStatusText(int status) {
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

  static Color getOrderStatusColor(int status) {
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
}
