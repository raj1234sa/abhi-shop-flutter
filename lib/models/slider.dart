import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Slider {
  final String id;
  final String imageUrl;
  final String sliderFor;
  String name;

  Slider(
      {@required this.id,
      @required this.imageUrl,
      this.name,
      @required this.sliderFor});

  Slider.fromJson(DocumentSnapshot json)
      : id = json.data()['id'],
        name = json.data()['name'],
        imageUrl = json.data()['imageUrl'],
        sliderFor = json.data()['sliderFor'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'sliderFor': sliderFor,
      };
}
