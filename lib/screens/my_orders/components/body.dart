import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/screens/my_orders/components/product_review_dialog.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/ordered_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final OrdersStream ordersStream = OrdersStream();

  @override
  void initState() {
    super.initState();
    ordersStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    ordersStream.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Your Orders",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.75,
                    child: buildOrdersList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    ordersStream.reload();
    return Future<void>.value();
  }

  Widget buildOrdersList() {
    return StreamBuilder<List<List<Map<String, dynamic>>>>(
      stream: ordersStream.stream as Stream<List<List<Map<String, dynamic>>>>,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final ordersList = snapshot.data;

          if (ordersList!.isEmpty) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_bag.svg",
                secondaryMessage: "Order something to show here",
              ),
            );
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: ordersList.length,
            itemBuilder: (context, index) {
              return FutureBuilder<List<OrderProducts>>(
                future: UserDatabaseHelper().getOrderedProductFromId(orderProductsIdsListGenerator(ordersList[index])),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final orderProductsIdsList = snapshot.data;
                    return buildOrderItem(orderProductsIdsList!, index, ordersList);
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    Logger().e(error);
                  }
                  return Icon(
                    Icons.error,
                    size: 60,
                    color: kTextColor,
                  );
                },
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Widget buildOrderItem(List<OrderProducts> orderProducts, int mainIndex, List<List<Map<String, dynamic>>> orderDate) {
    return FutureBuilder<List<Product>>(
      future: ProductDatabaseHelper().getProductsWithID(orderProducts.map((e) => e.id).toList()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Product> productsList = snapshot.data!;
          for (var i = 0; i < productsList.length; i++) {
            if (productsList[i].id == 'deleted') {
              productsList.removeAt(i);
            }
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ExpansionTile(title: Text('Order Date : ${UserDatabaseHelper.orderDate}'), maintainState: true, children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kTextColor.withOpacity(0.12),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        // text: "Ordered on:  ",
                        text: "",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(
                          color: kTextColor.withOpacity(0.15),
                        ),
                      ),
                    ),
                    // child: SizedBox(
                    //   width: double.infinity,
                    //   height: 300,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: orderDate[mainIndex].length,
                        itemBuilder: (context, index) {
                          return ProductShortDetailCard(
                            // productCount: orderDate[mainIndex][index]['item_count'] as int,
                            productCount: orderDate[mainIndex][index][productsList[index].id]?['item_count'],
                            productId: productsList[index].id,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productId: productsList[index].id,
                                  ),
                                ),
                              ).then((_) async {
                                await refreshPage();
                              });
                            },
                          );
                        }),
                    // ),
                  ),
                  /*Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        String currentUserUid = AuthentificationService().currentUser.uid;
                        Review? prevReview;
                        try {
                          prevReview = await ProductDatabaseHelper().getProductReviewWithID(productsList[mainIndex].id, currentUserUid);
                        } on FirebaseException catch (e) {
                          Logger().w("Firebase Exception: $e");
                        } catch (e) {
                          Logger().w("Unknown Exception: $e");
                        } finally {
                          prevReview ??= Review(
                            currentUserUid,
                            reviewerUid: currentUserUid,
                          );
                        }

                        final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return ProductReviewDialog(
                              review: prevReview!,
                            );
                          },
                        );
                        if (result is Review) {
                          bool reviewAdded = false;
                          String? snackbarMessage;
                          try {
                            reviewAdded = await ProductDatabaseHelper().addProductReview(productsList[mainIndex].id, result);
                            if (reviewAdded == true) {
                              snackbarMessage = "Product review added successfully";
                            } else {
                              throw "Coulnd't add product review due to unknown reason";
                            }
                          } on FirebaseException catch (e) {
                            Logger().w("Firebase Exception: $e");
                            snackbarMessage = e.toString();
                          } catch (e) {
                            Logger().w("Unknown Exception: $e");
                            snackbarMessage = e.toString();
                          } finally {
                            Logger().i(snackbarMessage);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(snackbarMessage!),
                              ),
                            );
                          }
                        }
                        await refreshPage();
                      },
                      child: Text(
                        "Give Product Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),*/
                ])
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final error = snapshot.error.toString();
          Logger().e(error);
        }
        return Icon(
          Icons.error,
          size: 60,
          color: kTextColor,
        );
      },
    );
  }

  List<String> orderProductsIdsListGenerator(List<Map<String, dynamic>> productsList) {
    List<String> orderProductsIdsList = [];
    for (var product in productsList) {
      orderProductsIdsList.addAll(product.keys);
    }
    return orderProductsIdsList;
  }
}
