import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;
  String description;
  final bool status;

  Category({
    @required this.id,
    @required this.name,
    @required this.imageUrl,
    this.description,
    @required this.status,
  });

  Category.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        name = json.data()['name'],
        description = json.data()['description'],
        status = json.data()['status'],
        imageUrl = json.data()['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'status': status,
      };
}
