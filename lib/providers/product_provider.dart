import 'dart:io';

import 'package:abhi_shop/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ProductProvider with ChangeNotifier {
  static List<Product> _products = [];
  static String keyword = '';
  static bool loading = true;

  List<Product> get items {
    return _products;
  }

  static Future<void> initProducts() async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    QuerySnapshot prodsnapshot = await _productsRef.get();
    List<Product> list = [];
    if (keyword.isNotEmpty) {
      prodsnapshot.docs.forEach((element) {
        Product prodObj = Product.fromJson(element);
        if (prodObj.productName.toLowerCase().contains(keyword.toLowerCase())) {
          list.add(prodObj);
        }
      });
    } else {
      prodsnapshot.docs.forEach((element) {
        list.add(Product.fromJson(element));
      });
    }
    _products = list;
    loading = false;
  }

  bool get isLoding {
    return loading;
  }

  List<Product> get activeItems {
    return _products.where((element) => element.status);
  }

  List<Product> get inactiveItems {
    return _products.where((element) => !element.status);
  }

  Future<void> setProducts() async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    QuerySnapshot prodsnapshot = await _productsRef.get();
    List<Product> list = [];
    if (keyword.isNotEmpty) {
      prodsnapshot.docs.forEach((element) {
        Product prodObj = Product.fromJson(element);
        if (prodObj.productName.toLowerCase().contains(keyword.toLowerCase())) {
          list.add(prodObj);
        }
      });
    } else {
      prodsnapshot.docs.forEach((element) {
        list.add(Product.fromJson(element));
      });
    }
    _products = list;
    loading = false;
    notifyListeners();
  }

  Product getProductData({@required id}) {
    return _products.firstWhere((element) => element.id == id);
  }

  Future<void> addEditProduct({@required Product product}) async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    await _productsRef.doc(product.id).set(product.toJson());
    await setProducts();
  }

  Future<String> uploadImage(File imageFile, String productId) async {
    final StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask = storageReference
        .child('products')
        .child('product_$productId.jpg')
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteProduct({@required id}) async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    StorageReference storageReference = FirebaseStorage.instance.ref();
    _productsRef
        .doc(
          id,
        )
        .delete()
        .then((value) async {
      await storageReference.child('products/product_$id.jpg').delete();
    });
    await setProducts();
  }

  enableSearch(value) {
    keyword = value;
    setProducts();
  }
}
