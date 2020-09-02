import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Product {
  String id;
  final String productName;
  final List<dynamic> sizePrices;
  final bool isNewArrival;
  final bool isHotProduct;
  final String imageUrl;
  final String categoryId;

  Product({
    @required this.id,
    @required this.productName,
    @required this.sizePrices,
    @required this.isHotProduct,
    @required this.isNewArrival,
    @required this.categoryId,
    this.imageUrl,
  });

  Product.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        productName = json.data()['productName'],
        sizePrices = json.data()['sizePrices'],
        isHotProduct = json.data()['isHotProduct'],
        imageUrl = json.data()['imageUrl'],
        isNewArrival = json.data()['isNewArrival'],
        categoryId = json.data()['categoryId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'sizePrices': sizePrices,
        'isHotProduct': isHotProduct,
        'isNewArrival': isNewArrival,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
      };
}
