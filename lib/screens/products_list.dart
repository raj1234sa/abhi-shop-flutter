import 'package:abhi_shop/screens/add_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class ProductListScreen extends StatelessWidget {
  static final ROUTE_NAME = 'products_list_screen';

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddProductScreen.ROUTE_NAME);
            },
          ),
        ],
      ),
      body: Container(
        child: Text('Listing'),
      ),
    );
  }
}
