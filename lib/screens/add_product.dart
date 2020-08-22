import 'package:abhi_shop/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

final _firestore = FirebaseFirestore.instance;

class AddProductScreen extends StatefulWidget {
  static final ROUTE_NAME = 'add_product_screen';
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
  bool _isHotProduct = false;
  bool _isNewArrival = true;

  _saveForm(BuildContext context) async {
    final isValidform = _formKey.currentState.validate();
    if (isValidform) {
      await Firebase.initializeApp();
      Product product = Product(
        id: DateTime.now().toString(),
        productName: _prodNameController.text,
        productSize: _prodSizeController.text,
        productPrice: double.parse(_prodPriceController.text),
        isHotProduct: _isHotProduct,
        isNewArrival: _isNewArrival,
      );
      await _firestore.collection('products').add(product.toJson());
      Navigator.pop(context);
    } else {}
  }

  @override
  void dispose() {
    _sizeNode.dispose();
    _priceNode.dispose();
    _prodNameController.dispose();
    _prodSizeController.dispose();
    _prodPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
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
              SwitchListTile(
                value: _isHotProduct,
                onChanged: (value) {
                  setState(() {
                    _isHotProduct = value;
                  });
                },
                title: Text('Hot Product'),
              ),
              SwitchListTile(
                value: _isNewArrival,
                onChanged: (value) {
                  setState(() {
                    _isNewArrival = value;
                  });
                },
                title: Text('New Arrival'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
