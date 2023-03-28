import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Address.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  static const String CART_COLLECTION_NAME = "cart";
  static const String ORDERED_PRODUCTS_COLLECTION_NAME = "ordered_products";

  static const String PHONE_KEY = 'phone';
  static const String DP_KEY = "display_picture";
  static const String FAV_PRODUCTS_KEY = "favourite_products";
  static const String USER_ROLE = "role";
  static String orderDate = 'none';

  UserDatabaseHelper._privateConstructor();
  static final UserDatabaseHelper _instance = UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() {
    return _instance;
  }
  late FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    _firebaseFirestore = FirebaseFirestore.instance;
    return _firebaseFirestore;
  }

  Future<void> createNewUser(String uid) async {
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      DP_KEY: null,
      PHONE_KEY: null,
      FAV_PRODUCTS_KEY: <String>[],
      USER_ROLE:'client'
    });
  }

  Future<String> get getCurrentUserRole async {
    String uid = AuthentificationService().currentUser.uid;
    DocumentSnapshot<Map> userDocData = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    final userRole = userDocData.data()?[USER_ROLE] ?? 'no-role';
    return userRole;
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser.uid;
    final docRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final cartCollectionRef = docRef.collection(CART_COLLECTION_NAME);
    final addressCollectionRef = docRef.collection(ADDRESSES_COLLECTION_NAME);
    final ordersCollectionRef = docRef.collection(ORDERED_PRODUCTS_COLLECTION_NAME);

    final cartDocs = await cartCollectionRef.get();
    for (final cartDoc in cartDocs.docs) {
      await cartCollectionRef.doc(cartDoc.id).delete();
    }
    final addressesDocs = await addressCollectionRef.get();
    for (final addressDoc in addressesDocs.docs) {
      await addressCollectionRef.doc(addressDoc.id).delete();
    }
    final ordersDoc = await ordersCollectionRef.get();
    for (final orderDoc in ordersDoc.docs) {
      await ordersCollectionRef.doc(orderDoc.id).delete();
    }

    await docRef.delete();
  }

  Future<bool> isProductFavourite(String productId) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final favList = userDocData![FAV_PRODUCTS_KEY].cast<String>();
    if (favList.contains(productId)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> get usersFavouriteProductsList async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final List purefavList = userDocData![FAV_PRODUCTS_KEY];
    final List<String> favList_before = [];
    for (var favItem in purefavList) {
      favList_before.add('$favItem');
    }
    final List<Product> favList_after = await ProductDatabaseHelper().getProductsWithID(favList_before);

    final List<String> favList = [];
    for (var product in favList_after) {
      favList.add(product.id);
    }
    return favList;
  }

  Future<bool> switchProductFavouriteStatus(String productId, bool newState) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);

    if (newState == true) {
      userDocSnapshot.update({
        FAV_PRODUCTS_KEY: FieldValue.arrayUnion([productId])
      });
    } else {
      userDocSnapshot.update({
        FAV_PRODUCTS_KEY: FieldValue.arrayRemove([productId])
      });
    }
    return true;
  }

  Future<List<String>> get addressesList async {
    String uid = AuthentificationService().currentUser.uid;
    final snapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).get();
    final addresses = <String>[];
    for (var doc in snapshot.docs) {
      addresses.add(doc.id);
    }

    return addresses;
  }

  Future<Address> getAddressFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final doc = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(id).get();
    final address = Address.fromMap((doc.data() as Map<String, dynamic>), id: doc.id);
    return address;
  }

  Future<bool> addAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressesCollectionReference = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME);
    await addressesCollectionReference.add(address.toMap());
    return true;
  }

  Future<bool> deleteAddressForCurrentUser(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(id);
    await addressDocReference.delete();
    return true;
  }

  Future<bool> updateAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(address.id);
    await addressDocReference.update(address.toMap());
    return true;
  }

  Future<CartItem> getCartItemFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(id);
    final docSnapshot = await docRef.get();
    final cartItem = CartItem.fromMap(docSnapshot.data()!, id: docSnapshot.id);
    return cartItem;
  }

  Future<bool> addProductToCart(String productId) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(productId);
    final docSnapshot = await docRef.get();
    bool alreadyPresent = docSnapshot.exists;
    if (alreadyPresent == false) {
      docRef.set(CartItem(itemCount: 1, id: productId).toMap());
    } else {
      docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    }
    return true;
  }

  Future<Map<String, Map<String, int>>> emptyCart() async {
    String uid = AuthentificationService().currentUser.uid;
    final cartItems = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME).get();
    Map<String, Map<String, int>> orderedProducts = {};
    for (final doc in cartItems.docs) {
      orderedProducts.addAll({
        doc.id: {"item_count": doc.data()['item_count']}
      });
      await doc.reference.delete();
    }
    return orderedProducts;
  }

  Future<num> get cartTotal async {
    String uid = AuthentificationService().currentUser.uid;
    final cartItems = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME).get();
    num total = 0.0;
    for (final doc in cartItems.docs) {
      num itemsCount = doc.data()[CartItem.ITEM_COUNT_KEY];
      final product = await ProductDatabaseHelper().getProductsWithID([doc.id]);
      total += (itemsCount * product[0].discountPrice!);
    }
    return num.parse(total.toStringAsFixed(2));
  }

  Future<bool> removeProductFromCart(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionReference = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    await cartCollectionReference.doc(cartItemID).delete();
    return true;
  }

  Future<bool> increaseCartItemCount(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    return true;
  }

  Future<bool> decreaseCartItemCount(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    final docSnapshot = await docRef.get();
    int currentCount = docSnapshot.data()![CartItem.ITEM_COUNT_KEY];
    if (currentCount <= 1) {
      return removeProductFromCart(cartItemID);
    } else {
      docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(-1)});
    }
    return true;
  }

  Future<List<String>> get allCartItemsList async {
    String uid = AuthentificationService().currentUser.uid;
    final querySnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME).get();
    List<String> itemsId = <String>[];
    for (final item in querySnapshot.docs) {
      itemsId.add(item.id);
    }
    return itemsId;
  }

  Future<List<List<Map<String, dynamic>>>> get ordersList async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedProductsSnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PRODUCTS_COLLECTION_NAME).get();
    List<List<Map<String, dynamic>>> ordersList = [];
    for (final doc in orderedProductsSnapshot.docs) {
      List<Map<String, dynamic>> orders = <Map<String, dynamic>>[];
      Map<String, dynamic> products = doc.data()['products'];
      String orderDate = doc.data()['order_date'];
      UserDatabaseHelper.orderDate = orderDate;
      for (var product in products.entries) {
        orders.add({product.key: product.value});
      }
      ordersList.addAll([orders]);
    }
    return ordersList;
  }

  Future<bool> addToMyOrders(OrderProducts order) async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedProductsCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PRODUCTS_COLLECTION_NAME);

    await orderedProductsCollectionRef.add({'products': order.products, 'order_date': order.orderDate, 'stripe_id': order.stripeId});

    return true;
  }

  Future<List<OrderProducts>> getOrderedProductFromId(List<String> ids) async {
    String uid = AuthentificationService().currentUser.uid;
    List<OrderProducts> orderedProduct = [];
    final doc = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PRODUCTS_COLLECTION_NAME).get();
    for (var id in ids) {
      if (id.isNotEmpty) {
        for (var doc in doc.docs) {
          doc.data();
          orderedProduct.add(OrderProducts.fromMap(doc.data()['products'], doc.data()['order_date'], id: id));
        }
      }
    }
    return orderedProduct;
  }

  Stream<DocumentSnapshot> get currentUserDataStream {
    String uid = AuthentificationService().currentUser.uid;
    return firestore.collection(USERS_COLLECTION_NAME).doc(uid).get().asStream();
  }

  Future<bool> updatePhoneForCurrentUser(String phone) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update({PHONE_KEY: phone});
    return true;
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = AuthentificationService().currentUser.uid;
    return "user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {DP_KEY: url},
    );
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {
        DP_KEY: FieldValue.delete(),
      },
    );
    return true;
  }

  Future<String?> get displayPictureForCurrentUser async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    return userDocSnapshot.data()?[DP_KEY];
  }
}
