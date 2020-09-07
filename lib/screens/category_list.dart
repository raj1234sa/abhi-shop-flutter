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

  List<Map> popupMenuList = [
    {
      'name': 'Edit',
      'icon': Icon(Icons.edit),
      'value': 'edit',
    },
    {
      'name': 'Copy ID',
      'icon': Icon(Icons.content_copy),
      'value': 'copyid',
    },
    {
      'name': 'Delete',
      'icon': Icon(
        Icons.delete,
        color: Colors.red,
      ),
      'value': 'delete',
    },
  ];

  Future<void> refreshCategories(BuildContext context) async {
    Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).setCategories();
  }

  void menuItemSelected(String selected, BuildContext context,
      {category}) async {
    switch (selected) {
      case 'edit':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCategoryScreen(
              editCategory: category,
            ),
          ),
        );
        break;
      case 'copyid':
        Clipboard.setData(
          ClipboardData(text: category.productId),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Category ID is copied to clipboard.'),
          ),
        );
        break;
      case 'delete':
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
                    await Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).deleteCategory(
                      id: category.productId,
                    );
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoryProvider>(context);
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
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15),
            child: Text(
              'Note: Background color indicates the status of product.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => refreshCategories(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    Category cat = categoryList[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: cat.status ? Colors.green[50] : Colors.red[50],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(cat.imageUrl),
                        ),
                        title: Text(cat.name),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            menuItemSelected(value, context, category: cat);
                          },
                          itemBuilder: (context) => popupMenuList
                              .map(
                                (menu) => PopupMenuItem(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    leading: menu['icon'],
                                    title: Text(menu['name']),
                                  ),
                                  value: menu['value'],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  itemCount: categoryList.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
