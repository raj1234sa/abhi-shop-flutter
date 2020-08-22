import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String productName;
  final String productSize;
  final double productPrice;
  final bool isNewArrival;
  final bool isHotProduct;
  final _firebase = FirebaseFirestore.instance;

  Product({
    @required this.id,
    @required this.productName,
    @required this.productSize,
    @required this.productPrice,
    @required this.isHotProduct,
    @required this.isNewArrival,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'productSize': productSize,
        'productPrice': productPrice,
        'isHotProduct': isHotProduct,
        'isNewArrival': isNewArrival,
      };
}
