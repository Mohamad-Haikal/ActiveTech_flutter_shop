import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../models/product_model.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts() async {
    final List<Product> loadedProducts = [];
    try {
      await FirebaseFirestore.instance.collection('products').get().then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final Product product = Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          loadedProducts.add(product);
        }
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');
      final DocumentReference docRef = await productsCollection.add(product.toMap());
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    try {
      final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');
      await productsCollection.doc(id).update(newProduct.toMap());
      final productIndex = _items.indexWhere((product) => product.id == id);
      if (productIndex >= 0) {
        _items[productIndex] = newProduct;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');
      await productsCollection.doc(id).delete();
      _items.removeWhere((product) => product.id == id);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<String> uploadImage(String path, String imageName) async {
    try {
      final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(path);
      final firebase_storage.UploadTask uploadTask = ref.putFile(File(imageName));
      final url = await (await uploadTask).ref.getDownloadURL();
      return url;
    } catch (error) {
      rethrow;
    }
  }
}
