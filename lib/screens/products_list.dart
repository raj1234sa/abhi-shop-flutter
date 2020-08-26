import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  static final ROUTE_NAME = 'products_list_screen';

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');
  List<Product> _allProducts = [];
  List<Product> _visibleProducts = [];
  String _productSearchTitle = '';
  final _productSearchController = TextEditingController();

  @override
  void initState() {
    getAllProducts();
    super.initState();
  }

  void getAllProducts() async {
    await _productsRef.get().then((value) {
      setState(() {
        _allProducts = value.docs
            .map(
              (e) => Product.fromJson(e),
            )
            .toList();
        _visibleProducts = _allProducts;
      });
    });
  }

  void searchProduct() {
    if (_productSearchController.text.isEmpty) {
      setState(() {
        _visibleProducts = _allProducts;
      });
    } else {
      setState(() {
        _visibleProducts = _allProducts
            .where((e) => e.productName.contains(_productSearchController.text))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: TextFormField(
              controller: _productSearchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Products...',
                suffix: _productSearchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _productSearchController.clear();
                          searchProduct();
                          FocusScope.of(context).unfocus();
                        },
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).errorColor,
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                searchProduct();
              },
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_visibleProducts[index].productName),
                      subtitle: Text(
                        "",
                      ),
                      trailing: Container(
                        width: MediaQuery.of(context).size.width * .27,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AddProductScreen.ROUTE_NAME,
                                  arguments: _visibleProducts[index],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Theme.of(context).errorColor,
                              onPressed: () {
                                _productsRef
                                    .doc(_visibleProducts[index].docId)
                                    .delete()
                                    .then((value) {
                                  setState(() {
                                    _productsRef = FirebaseFirestore.instance
                                        .collection('products');
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ));
                },
                itemCount: _visibleProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
