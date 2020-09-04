import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Slider {
  final String id;
  final String imageUrl;
  String name;

  Slider({@required this.id, @required this.imageUrl, this.name});

  Slider.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        name = json.data()['name'],
        imageUrl = json.data()['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };
}
