import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/cart/components/checkout_card.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/data_streams/cart_items_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../utils.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final CartItemsStream cartItemsStream = CartItemsStream();
  late PersistentBottomSheetController bottomSheetHandler;
  static String secret = 'sk_test_51MiOFqCca33SRveICK6yEM7AqPXhbRVxtWgkkDm7K8dYZ79CbWWr4aAVII7fxExduvgxmDkSQSjmn9ukjXF6Crfg00nZwSM6of';

  @override
  void initState() {
    super.initState();
    cartItemsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    cartItemsStream.dispose();
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
                    "Your Cart",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.75,
                    child: Center(
                      child: buildCartItemsList(),
                    ),
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
    cartItemsStream.reload();
    Scaffold.of(context).showBottomSheet(
      (context) {
        return CheckoutCard(
          onCheckoutPressed: checkoutButtonCallback,
        );
      },
    );
    return Future<void>.value();
  }

  Widget buildCartItemsList() {
    return StreamBuilder<List<String>>(
      stream: cartItemsStream.stream as Stream<List<String>>,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> cartItemsId = snapshot.data!;
          if (cartItemsId.isEmpty) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_cart.svg",
                secondaryMessage: "Your cart is empty",
              ),
            );
          }

          return Column(
            children: [
              DefaultButton(
                text: "Proceed to Payment",
                press: () {
                  bottomSheetHandler = Scaffold.of(context).showBottomSheet(
                    (context) {
                      return CheckoutCard(
                        onCheckoutPressed: checkoutButtonCallback,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  physics: BouncingScrollPhysics(),
                  itemCount: cartItemsId.length,
                  itemBuilder: (context, index) {
                    if (index >= cartItemsId.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return buildCartItemDismissible(context, cartItemsId[index], index);
                  },
                ),
              ),
            ],
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

  Widget buildCartItemDismissible(BuildContext context, String cartItemId, int index) {
    return Dismissible(
      key: Key(cartItemId),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItemId, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Product from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              bool result = false;
              String? snackbarMessage;
              try {
                result = await UserDatabaseHelper().removeProductFromCart(cartItemId);
                if (result == true) {
                  snackbarMessage = "Product removed from cart successfully";
                  await refreshPage();
                } else {
                  throw "Coulnd't remove product from cart due to unknown reason";
                }
              } on FirebaseException catch (e) {
                Logger().w("Firebase Exception: $e");
                snackbarMessage = "Something went wrong";
              } catch (e) {
                Logger().w("Unknown Exception: $e");
                snackbarMessage = "Something went wrong";
              } finally {
                Logger().i(snackbarMessage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackbarMessage!),
                  ),
                );
              }

              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(String cartItemId, int index) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<List<Product>>(
        future: ProductDatabaseHelper().getProductsWithID([cartItemId]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Product product = snapshot.data![0];
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
                  child: ProductShortDetailCard(
                    productCount: null,
                    productId: product.id,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kTextColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowUpCallback(cartItemId);
                          },
                        ),
                        SizedBox(height: 8),
                        FutureBuilder<CartItem>(
                          future: UserDatabaseHelper().getCartItemFromId(cartItemId),
                          builder: (context, snapshot) {
                            int itemCount = 0;
                            if (snapshot.hasData) {
                              final cartItem = snapshot.data;
                              itemCount = cartItem!.itemCount;
                            } else if (snapshot.hasError) {
                              final error = snapshot.error.toString();
                              Logger().e(error);
                            }
                            return Text(
                              "$itemCount",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: kTextColor,
                          ),
                          onTap: () async {
                            await arrowDownCallback(cartItemId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
            return Center(
              child: Text(
                error.toString(),
              ),
            );
          } else {
            return Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkoutButtonCallback() async {
    final cartAmount = (await UserDatabaseHelper().cartTotal).toDouble();
    var paymentResult;
    // define function "calculateAmount" to convert dollars to cents "amount(dollar) * 100 = cents"
    calculateAmount(double amount) {
      double jodToUsd = amount * 1.41;
      jodToUsd = double.parse(jodToUsd.toStringAsFixed(2));
      double calculatedAmount = jodToUsd * 100;
      return calculatedAmount.toInt().toString();
    }

    // define function "createPaymentIntent" to create payment intent (http post to stripe api) with the parameters -amount -currency
    createPaymentIntent(double amount, String currency) async {
      try {
        Map<String, dynamic> body = {'amount': calculateAmount(amount), 'currency': currency, 'payment_method_types[]': 'card'};
        var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
            headers: {'Authorization': 'Bearer $secret', 'Content-Type': 'application/x-www-form-urlencoded'}, body: body);
        print('Payment Intent Body --====>>> ${response.body.toString()}');
        return jsonDecode(response.body);
      } catch (e) {
        print('this error have happend in cpi = $e');
        throw 'error';
      }
    }

    // define function "createOrderAndRefreshPage" to delete cart after the payment have successfull then create a new order
    createOrderAndRefreshPage(Map paymentIntent) async {
      final orderFuture = UserDatabaseHelper().emptyCart();
      orderFuture.then((orderedProductsUid) async {
        if (orderedProductsUid != null) {
          final dateTime = DateTime.now();
          OrderProducts orderedProducts = OrderProducts('', products: orderedProductsUid, orderDate: '$dateTime', stripeId: paymentIntent['id']);
          bool addedProductsToMyProducts = false;
          String? snackbarmMessage;
          try {
            addedProductsToMyProducts = await UserDatabaseHelper().addToMyOrders(orderedProducts);
            if (addedProductsToMyProducts) {
              snackbarmMessage = "Products ordered Successfully";
              refreshPage();
            } else {
              throw "Could not order products due to unknown issue";
            }
          } on FirebaseException catch (e) {
            Logger().e(e.toString());
            snackbarmMessage = e.toString();
          } catch (e) {
            Logger().e(e.toString());
            snackbarmMessage = e.toString();
          } finally {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackbarmMessage ?? "Something went wrong"),
              ),
            );
          }
        } else {
          throw "Something went wrong while clearing cart";
        }
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              orderFuture,
              message: Text("Placing the Order"),
            );
          },
        );
      }).catchError((e) {
        Logger().e(e.toString());
      });
      await refreshPage();
    }

    // define function "displayPaymentSheet" to present payment sheet details and show if it pass or not and show alert dialog that said "Payment Successfull"
    displayPaymentSheet(Map paymentIntent) async {
      try {
        await Stripe.instance
            .presentPaymentSheet()
            .then((value) => showDialog(
                  context: context,
                  builder: (context) {
                    paymentResult = 200;
                    createOrderAndRefreshPage(paymentIntent);
                    return AlertDialog(
                      actions: [
                        TextButton(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              Text("Payment Successfull")
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ))
            .onError((error, stackTrace) => print('error is ====>> $error   //////    $stackTrace'));
      } on StripeException catch (e) {
        print('errroorr id ++++>>>>> $e');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text('canceled'),
                ));
      }
    }

    // define function "makePayment" to create variable instance of "createPaymentIntent" and give it the amount and currency parameteres and initilaize a payment sheet
    Future<void> makePayment() async {
      try {
        bool isDialog = false;
        if (isDialog == false) {
          showDialog(
              context: context,
              builder: (context) {
                return Center(child: CircularProgressIndicator());
              });
          isDialog = true;
        }
        var paymentIntent = await createPaymentIntent(cartAmount, 'usd');
        // create payment sheet
        await Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: SetupPaymentSheetParameters(
                    paymentIntentClientSecret: paymentIntent['client_secret'],
                    // applePay: const PaymentSheetApplePay(merchantCountryCode: '+962'),
                    // googlePay: const PaymentSheetGooglePay(merchantCountryCode: '+962', currencyCode: "USD", testEnv: true),
                    style: ThemeMode.dark,
                    merchantDisplayName: 'Active Tech'))
            .then((value) {
          if (isDialog == true) {
            Navigator.pop(context);
            isDialog = false;
          }
        });
        await displayPaymentSheet(paymentIntent);

        print('paymentResult = $paymentResult');

        if (paymentResult != null) {
          if (paymentResult == 200) {
            // now finally display payment sheet
            // await createOrderAndRefreshPage(paymentIntent);
            paymentIntent = null;
          } else {
            paymentIntent = null;
            return;
          }
        }
      } catch (e, s) {
        print('this error have happend in mp --====>>> $e ///// $s');
      }
    }

    // get cart amount and check if its equal zero(empty) or not
    if (cartAmount > 0) {
      makePayment();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Please add at least one product to checkout'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
  }

  void shutBottomSheet() {
    bottomSheetHandler.close();
  }

  Future<void> arrowUpCallback(String cartItemId) async {
    final future = UserDatabaseHelper().increaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      Logger().e(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong"),
      ));
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AsyncProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }

  Future<void> arrowDownCallback(String cartItemId) async {
    final future = UserDatabaseHelper().decreaseCartItemCount(cartItemId);
    future.then((status) async {
      if (status) {
        await refreshPage();
      } else {
        throw "Couldn't perform the operation due to some unknown issue";
      }
    }).catchError((e) {
      Logger().e(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong"),
      ));
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AsyncProgressDialog(
          future,
          message: Text("Please wait"),
        );
      },
    );
  }
}
