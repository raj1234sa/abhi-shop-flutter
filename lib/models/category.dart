import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({@required this.id, @required this.name, @required this.imageUrl});

  Category.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        name = json.data()['name'],
        imageUrl = json.data()['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };

  String getCategoryName() {
    return this.name;
  }
}
