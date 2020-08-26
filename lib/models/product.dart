import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String productName;
  final Map<String, Object> sizePrices;
  // final String productSize;
  // final double productPrice;
  final bool isNewArrival;
  final bool isHotProduct;
  String docId;

  Product({
    @required this.id,
    @required this.productName,
    // @required this.productSize,
    // @required this.productPrice,
    @required this.sizePrices,
    @required this.isHotProduct,
    @required this.isNewArrival,
    this.docId,
  });

  Product.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        docId = json.id,
        productName = json.data()['productName'],
        sizePrices = json.data()['sizePrices'],
        // productSize = json.data()['productSize'],
        // productPrice = json.data()['productPrice'],
        isHotProduct = json.data()['isHotProduct'],
        isNewArrival = json.data()['isNewArrival'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        // 'productSize': productSize,
        // 'productPrice': productPrice,
        'isHotProduct': isHotProduct,
        'isNewArrival': isNewArrival,
      };
}
