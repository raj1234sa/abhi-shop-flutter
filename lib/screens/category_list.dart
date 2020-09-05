import 'package:abhi_shop/models/category.dart';
import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/screens/add_category.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

final StorageReference storageReference = FirebaseStorage.instance.ref();

class CategoryListScreen extends StatelessWidget {
  static final String ROUTE_NAME = "category_list_screen";

  Future<void> refreshCategories(BuildContext context) async {
    Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).setCategories();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryProvider>(context);
    categoriesProvider.setCategories();
    final categoryList = categoriesProvider.items;
    return Scaffold(
      drawer: MainDrawer(),
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
      body: RefreshIndicator(
        onRefresh: () => refreshCategories(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            itemBuilder: (context, index) {
              Category cat = categoryList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(cat.imageUrl),
                ),
                title: Text(cat.name),
                trailing: Container(
                  width: MediaQuery.of(context).size.width * .40,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Copy ID',
                        icon: Icon(Icons.content_copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: cat.id),
                          );
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Category ID is copied to clipboard.'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryScreen(
                                editProduct: cat,
                              ),
                            ),
                          );
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
                                  'Are you sure to delete the category??',
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('No'),
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      await categoriesProvider.deleteCategory(
                                        id: cat.id,
                                      );
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
            itemCount: categoryList.length,
          ),
        ),
      ),
    );
  }
}
