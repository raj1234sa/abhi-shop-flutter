import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final StorageReference storageReference = FirebaseStorage.instance.ref();

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
  final _productSearchController = TextEditingController();
  bool _loading = true;
  bool _noProducts = false;

  @override
  void initState() {
    getAllProducts();
    setState(() {
      _loading = false;
    });
    super.initState();
  }

  Future<void> getAllProducts() async {
    _productsRef.get().then((value) {
      setState(() {
        _allProducts = value.docs
            .map(
              (e) => Product.fromJson(e),
            )
            .toList();
        _visibleProducts = _allProducts;
        if (_visibleProducts.isEmpty) {
          _noProducts = true;
        }
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
        print(_visibleProducts.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: SafeArea(
            child: Text('Shop Head'),
          ),
        ),
      ),
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
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                                Icons.close,
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
                if (_visibleProducts.length > 0)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => getAllProducts(),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _visibleProducts[index].imageUrl),
                                ),
                                title:
                                    Text(_visibleProducts[index].productName),
                                subtitle: Text(
                                  "",
                                ),
                                trailing: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .27,
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddProductScreen(
                                                editProduct:
                                                    _visibleProducts[index],
                                              ),
                                            ),
                                          );
                                          getAllProducts();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Theme.of(context).errorColor,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Warning'),
                                                content: Text(
                                                  'Are you sure to delete the product??',
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: Text('No'),
                                                  ),
                                                  FlatButton(
                                                    onPressed: () {
                                                      String prodId =
                                                          _visibleProducts[
                                                                  index]
                                                              .id;
                                                      _productsRef
                                                          .doc(
                                                            prodId,
                                                          )
                                                          .delete()
                                                          .then((value) async {
                                                        storageReference
                                                            .child(
                                                                'products/product_$prodId.jpg')
                                                            .delete()
                                                            .then((value) {});
                                                        setState(() {
                                                          _productsRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'products');
                                                          getAllProducts();
                                                        });
                                                      });
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
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
                  ),
              ],
            ),
    );
  }
}
