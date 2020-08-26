import 'package:abhi_shop/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

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
  Product editProductData;

  final _prodNameController = TextEditingController();
  final _prodSizeController = TextEditingController();
  final _prodPriceController = TextEditingController();
  List<Map<String, TextEditingController>> _priceSizeControllers = [
    {
      'size': TextEditingController(),
      'price': TextEditingController(),
    },
  ];

  List<Map<String, FocusNode>> _focusNodes = [
    {
      'size': FocusNode(),
      'price': FocusNode(),
    },
  ];

  bool _isHotProduct = false;
  bool _isNewArrival = true;
  bool initstate = false;

  _saveForm(BuildContext context) async {
    final isValidform = _formKey.currentState.validate();
    if (isValidform) {
      await Firebase.initializeApp();
      Product product = Product(
        id: editProductData == null
            ? DateTime.now().toString()
            : editProductData.id,
        productName: _prodNameController.text,
        // productSize: _prodSizeController.text,
        // productPrice: double.parse(_prodPriceController.text),
        isHotProduct: _isHotProduct,
        isNewArrival: _isNewArrival,
      );
      if (editProductData == null) {
        await _firestore.collection('products').add(product.toJson());
        Toast.show(
          'Product is added!!',
          context,
          duration: Toast.LENGTH_LONG + 5,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      } else {
        await _firestore
            .collection('products')
            .doc(editProductData.docId)
            .set(product.toJson());
        Toast.show(
          'Product is updated!!',
          context,
          duration: Toast.LENGTH_LONG + 5,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      }
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
  void didChangeDependencies() {
    if (initstate == false) {
      Product prodDoc = ModalRoute.of(context).settings.arguments;
      if (prodDoc != null) {
        _prodNameController.text = prodDoc.productName;
        // _prodSizeController.text = prodDoc.productSize;
        // _prodPriceController.text = prodDoc.productPrice.toString();
        _isHotProduct = prodDoc.isHotProduct;
        _isNewArrival = prodDoc.isNewArrival;
        editProductData = prodDoc;
      }
      setState(() {
        initstate = true;
      });
    }
    super.didChangeDependencies();
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
                  FocusScope.of(context).requestFocus(_focusNodes[0]['size']);
                },
              ),
              ..._priceSizeControllers.map((e) {
                int index = _priceSizeControllers.indexOf(e);
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _priceSizeControllers[index]['size'],
                        decoration: InputDecoration(
                          labelText: 'Product Size',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Product size is required.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index]['price']);
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _focusNodes[index]['size'],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _priceSizeControllers[index]['price'],
                        decoration: InputDecoration(
                          labelText: 'Product Price',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Product price is required.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]['size']);
                        },
                        textInputAction: TextInputAction.next,
                        focusNode: _focusNodes[index]['price'],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (_priceSizeControllers.length > 1)
                      GestureDetector(
                        child: Icon(
                          Icons.delete,
                        ),
                        onTap: () {
                          setState(() {
                            _priceSizeControllers.removeAt(index);
                            _focusNodes.removeAt(index);
                          });
                        },
                      ),
                  ],
                );
              }),
              RaisedButton.icon(
                onPressed: () {
                  setState(() {
                    _priceSizeControllers.add({
                      'size': TextEditingController(),
                      'price': TextEditingController(),
                    });
                    _focusNodes.add({
                      'size': FocusNode(),
                      'price': FocusNode(),
                    });
                  });
                },
                icon: Icon(Icons.add),
                label: Text('Add Size'),
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
