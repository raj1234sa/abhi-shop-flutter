import 'package:abhi_shop/models/category.dart';
import 'package:abhi_shop/screens/add_category.dart';
import 'package:abhi_shop/screens/products_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final StorageReference storageReference = FirebaseStorage.instance.ref();

class CategoryListScreen extends StatefulWidget {
  static final String ROUTE_NAME = "category_list_screen";
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  CollectionReference _categoryRef =
      FirebaseFirestore.instance.collection('categories');
  List<Category> _categoryList = [];
  bool _isLoading = true;

  Future<void> getAllCategories() async {
    _categoryRef.get().then((value) {
      setState(() {
        _categoryList =
            value.docs.map((cat) => Category.fromJson(cat)).toList();
      });
    }).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('Products'),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context)
                        .pushReplacementNamed(ProductListScreen.ROUTE_NAME);
                  },
                ),
                ListTile(
                  title: Text('Cateogries'),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context)
                        .pushReplacementNamed(CategoryListScreen.ROUTE_NAME);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Categories"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddCategoryScreen.ROUTE_NAME);
            },
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(_categoryList[index].imageUrl),
                    ),
                    title: Text(_categoryList[index].name),
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
                                  builder: (context) => AddCategoryScreen(
                                    editProduct: _categoryList[index],
                                  ),
                                ),
                              );
                              getAllCategories();
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
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('No'),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          String catId =
                                              _categoryList[index].id;
                                          _categoryRef
                                              .doc(
                                                catId,
                                              )
                                              .delete()
                                              .then((value) async {
                                            storageReference
                                                .child(
                                                    'categories/category_$catId.jpg')
                                                .delete()
                                                .then((value) {});
                                            setState(() {
                                              _categoryRef = FirebaseFirestore
                                                  .instance
                                                  .collection('categories');
                                              getAllCategories();
                                            });
                                          });
                                          Navigator.of(context).pop(true);
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
                    ),
                  );
                },
                itemCount: _categoryList.length,
              ),
            ),
    );
  }
}
