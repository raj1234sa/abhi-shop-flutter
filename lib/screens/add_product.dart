import 'package:abhi_shop/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sizeNode = FocusNode();
  final _priceNode = FocusNode();

  final _prodNameController = TextEditingController();
  final _prodSizeController = TextEditingController();
  final _prodPriceController = TextEditingController();

  _saveForm(BuildContext context) {
    final isValidform = _formKey.currentState.validate();
    if (isValidform) {
      Product product = Product(
        id: DateTime.now().toString(),
        productName: _prodNameController.text,
        productSize: _prodSizeController.text,
        productPrice: double.parse(_prodPriceController.text),
        isHotProduct: true,
        isNewArrival: true,
      );
      _firestore.collection('products').add(product.toJson());
    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Abhishek Vasan Bhandar"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm(context);
            },
          ),
        ],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            children: <Widget>[
              TextFormField(
                controller: _prodNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Product name is required.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_sizeNode);
                },
              ),
              TextFormField(
                controller: _prodSizeController,
                decoration: InputDecoration(
                  labelText: 'Product Size',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Product size is required.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceNode);
                },
                focusNode: _sizeNode,
              ),
              TextFormField(
                controller: _prodPriceController,
                decoration: InputDecoration(
                  labelText: 'Product Price',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Product price is required.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Product price must be numerics.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                focusNode: _priceNode,
                onFieldSubmitted: (_) {
                  _saveForm(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
