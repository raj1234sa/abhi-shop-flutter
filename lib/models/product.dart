import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Product {
  String id;
  final String productName;
  final List<dynamic> sizePrices;
  final bool isNewArrival;
  final bool isHotProduct;
  final String imageUrl;

  Product({
    @required this.id,
    @required this.productName,
    @required this.sizePrices,
    @required this.isHotProduct,
    @required this.isNewArrival,
    this.imageUrl,
  });

  Product.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        productName = json.data()['productName'],
        sizePrices = json.data()['sizePrices'],
        isHotProduct = json.data()['isHotProduct'],
        imageUrl = json.data()['imageUrl'],
        isNewArrival = json.data()['isNewArrival'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'sizePrices': sizePrices,
        'isHotProduct': isHotProduct,
        'isNewArrival': isNewArrival,
        'imageUrl': imageUrl,
      };
}
