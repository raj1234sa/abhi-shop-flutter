import 'dart:io';

import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/models/stock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  static List<Product> _products = [];
  static List<Stock> _stocks = [];
  static String keyword = '';
  static bool loading = true;

  List<Product> get items {
    return _products;
  }

  Future<dynamic> manageStock({productId, stockId, amount, mode}) async {
    CollectionReference _stockRef =
        FirebaseFirestore.instance.collection('stock');
    var status = null;
    _stockRef.doc(productId).get().then((value) {
      Stock stockObj = Stock.fromJson(value);
      List stockList = stockObj.stockData;
      if (mode == '+') {
        stockList[stockId]['$stockId'] =
            stockList[stockId]['$stockId'] + int.parse(amount);
        _stockRef.doc(productId).set(stockObj.toJson());
      } else if (mode == '-' &&
          (stockList[stockId]['$stockId'] - int.parse(amount)) >= 0) {
        stockList[stockId]['$stockId'] =
            stockList[stockId]['$stockId'] - int.parse(amount);
        _stockRef.doc(productId).set(stockObj.toJson());
      } else {
        status = [
          'Stock Debit amount is more than remaining stock',
          Colors.red
        ];
      }
    });
    await setProducts();
    return status;
  }

  static Future<void> initProducts() async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    CollectionReference _stockRef =
        FirebaseFirestore.instance.collection('stock');
    QuerySnapshot prodsnapshot = await _productsRef.get();
    QuerySnapshot stocksnapshot = await _stockRef.get();
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
    List<Stock> stocklist = [];
    stocksnapshot.docs.forEach((element) {
      stocklist.add(Stock.fromJson(element));
    });
    _products = list;
    _stocks = stocklist;
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
    CollectionReference _stockRef =
        FirebaseFirestore.instance.collection('stock');
    QuerySnapshot prodsnapshot = await _productsRef.get();
    QuerySnapshot stocksnapshot = await _stockRef.get();
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
    List<Stock> stocklist = [];
    stocksnapshot.docs.forEach((element) {
      stocklist.add(Stock.fromJson(element));
    });
    _products = list;
    _stocks = stocklist;
    loading = false;
    notifyListeners();
  }

  Stock getStockData({productId}) {
    return _stocks.firstWhere((element) => element.productId == productId);
  }

  Product getProductData({@required id}) {
    return _products.firstWhere((element) => element.id == id);
  }

  Future<void> addEditProduct({
    @required Product product,
    @required bool addMode,
  }) async {
    CollectionReference _productsRef =
        FirebaseFirestore.instance.collection('products');
    CollectionReference _stockRef =
        FirebaseFirestore.instance.collection('stock');
    await _productsRef.doc(product.id).set(product.toJson());
    if (addMode) {
      List<Map<String, int>> stockData = product.sizePrices.map((e) {
        String id = product.sizePrices.indexOf(e).toString();
        return {id: 0};
      }).toList();
      Stock stock = Stock(
        productId: product.id,
        stockData: stockData,
      );
      print(stock.stockData);
      await _stockRef.doc(product.id).set(stock.toJson());
    }
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
