import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String productName;
  final String productSize;
  final double productPrice;
  final bool isNewArrival;
  final bool isHotProduct;

  Product({
    @required this.id,
    @required this.productName,
    @required this.productSize,
    @required this.productPrice,
    @required this.isHotProduct,
    @required this.isNewArrival,
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productName = json['productName'],
        productSize = json['productSize'],
        productPrice = json['productPrice'],
        isHotProduct = json['isHotProduct'],
        isNewArrival = json['isNewArrival'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'productSize': productSize,
        'productPrice': productPrice,
        'isHotProduct': isHotProduct,
        'isNewArrival': isNewArrival,
      };
}
