import 'package:e_commerce_app_flutter/components/async_progress_dialog.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
import 'package:e_commerce_app_flutter/screens/category_products/category_products_screen.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/all_products_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/favourite_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../services/data_streams/cart_items_stream.dart';
import '../../../utils.dart';
import '../components/home_header.dart';
import 'product_type_box.dart';
import 'products_section.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String PRODUCT_TYPE_KEY = "product_type";

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final productCategories = <Map>[
    <String, dynamic>{
      ICON_KEY: "assets/icons/computer-electronics.svg",
      TITLE_KEY: "Computer",
      PRODUCT_TYPE_KEY: ProductType.Computer,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/cpu-charge.svg",
      TITLE_KEY: "Cpu",
      PRODUCT_TYPE_KEY: ProductType.Cpu,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/ram-memory.svg",
      TITLE_KEY: "Ram",
      PRODUCT_TYPE_KEY: ProductType.Ram,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/keyboard.svg",
      TITLE_KEY: "Keyboard",
      PRODUCT_TYPE_KEY: ProductType.Keyboard,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/mouse.svg",
      TITLE_KEY: "Mouse",
      PRODUCT_TYPE_KEY: ProductType.Mouse,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/music-box-speakers.svg",
      TITLE_KEY: "Speakers",
      PRODUCT_TYPE_KEY: ProductType.Speakers,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/monitor.svg",
      TITLE_KEY: "Monitors",
      PRODUCT_TYPE_KEY: ProductType.Monitors,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/harddisk.svg",
      TITLE_KEY: "Storage",
      PRODUCT_TYPE_KEY: ProductType.Storage,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/laptop.svg",
      TITLE_KEY: "Laptops",
      PRODUCT_TYPE_KEY: ProductType.Laptops,
    },
  ];

  final FavouriteProductsStream favouriteProductsStream = FavouriteProductsStream();
  final AllProductsStream allProductsStream = AllProductsStream();
  final CartItemsStream cartItemsStream = CartItemsStream();
  final ScrollController pageScrollController = ScrollController();
  final ScrollController gridListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    favouriteProductsStream.init();
    allProductsStream.init();
    cartItemsStream.init();
  }

  @override
  void dispose() {
    favouriteProductsStream.dispose();
    allProductsStream.dispose();
    cartItemsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          controller: pageScrollController,
          // physics: (),
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  cartItemsStreamController: cartItemsStream,
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.isEmpty) return;
                    List<String> searchedProductsId;
                    try {
                      searchedProductsId = await ProductDatabaseHelper().searchInProducts(query.toLowerCase(), productType: null);
                      if (searchedProductsId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultProductsId: searchedProductsId,
                              searchIn: "All Products",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Couldn't perform search due to some unknown reason";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
                    bool allowed = AuthentificationService().currentUserVerified;
                    if (!allowed) {
                      final reverify = await showConfirmationDialog(
                          context, "You haven't verified your email address. This action is only allowed for verified users.",
                          positiveResponse: "Resend verification email", negativeResponse: "Go back");
                      if (reverify) {
                        final future = AuthentificationService().sendVerificationEmailToCurrentUser();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AsyncProgressDialog(
                              future,
                              message: Text("Resending verification email"),
                            );
                          },
                        );
                      }
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...List.generate(
                          productCategories.length,
                          (index) {
                            return ProductTypeBox(
                              icon: productCategories[index][ICON_KEY],
                              title: productCategories[index][TITLE_KEY],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryProductsScreen(
                                      productType: productCategories[index][PRODUCT_TYPE_KEY],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: getProportionateScreenHeight(20)),
                // SizedBox(
                //   height: SizeConfig.screenHeight! * 0.4,
                //   child: ProductsSection(
                //     sectionTitle: "Electronics",
                //     productsStreamController: favouriteProductsStream,
                //     emptyListMessage: "Add Product to Favourites",
                //     onProductCardTapped: onProductCardTapped,
                //     onArrowPressed: () {
                //       MaterialPageRoute(
                //         builder: (context) => CategoryProductsScreen(
                //           productType: productCategories[0][PRODUCT_TYPE_KEY],
                //         ),
                //       );
                //     },
                //     scrollDirection: Axis.horizontal,
                //   ),
                // ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.5,
                  child: ProductsSection(
                    sectionTitle: "Products You Like",
                    productsStreamController: favouriteProductsStream,
                    emptyListMessage: "Add Product to Favourites",
                    onProductCardTapped: onProductCardTapped,
                    scrollDirection: Axis.horizontal,
                    scrollController: gridListScrollController,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox.fromSize(
                  size: Size.fromHeight(SizeConfig.screenHeight! * 0.8),
                  // height: SizeConfig.screenHeight! * 0.8,
                  child: ProductsSection(
                    sectionTitle: "Explore All Products",
                    productsStreamController: allProductsStream,
                    emptyListMessage: "Looks like all Stores are closed",
                    onProductCardTapped: onProductCardTapped,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouriteProductsStream.reload();
    allProductsStream.reload();
    cartItemsStream.reload();
    return Future<void>.value();
  }

  void onProductCardTapped(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: productId),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
}
