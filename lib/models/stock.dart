import 'package:cloud_firestore/cloud_firestore.dart';

class Stock {
  String productId;
  List<Map<String, int>> stockData;

  Stock({
    this.productId,
    this.stockData,
  });

  Stock.fromJson(DocumentSnapshot json) {
    productId = json.id;
    stockData = json.data()["stockData"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["productId"] = productId;
    map["stockData"] = stockData;
    return map;
  }
}
