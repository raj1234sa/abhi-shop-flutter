import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    setState(() {
      _loading = true;
    });
    getAllProducts();
    super.initState();
  }

  Future<void> getAllProducts() async {
    _productsRef.get().then((value) {
      _allProducts = value.docs
          .map(
            (e) => Product.fromJson(e),
          )
          .toList();
      _visibleProducts = _allProducts;
      if (_visibleProducts.isEmpty) {
        _noProducts = true;
      }
      setState(() {
        _loading = false;
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
          ? Shimmer.fromColors(
              period: Duration(seconds: 2),
              baseColor: Colors.grey[100],
              highlightColor: Colors.grey[400],
              direction: ShimmerDirection.rtl,
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: IconButton(
                            onPressed: null,
                            icon :Icon(Icons.search,size: 30.0,),
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 15.0,
                            ),
                            height: 30,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    ...List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24.0,
                              backgroundColor: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                  ),
                                  Container(
                                    width: 40.0,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    })
                  ],
                ),
              ),
            )
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
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                              leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _visibleProducts[index].imageUrl)),
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
                                                'Are you sure to delete the ${_visibleProducts[index].productName} ?',
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
                                                  onPressed: () async {
                                                    String prodId =
                                                        _visibleProducts[index]
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
              ],
            ),
    );
  }
}
