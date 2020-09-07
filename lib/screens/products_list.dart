import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductListScreen extends StatelessWidget {
  static final ROUTE_NAME = 'products_list_screen';
  final _productSearchController = TextEditingController();
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

  Future<void> getAllProducts(BuildContext context) async {
    Provider.of<ProductProvider>(context, listen: false).setProducts();
  }

  void menuItemSelected(String selected, BuildContext context,
      {product}) async {
    switch (selected) {
      case 'edit':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductScreen(
              editProduct: product,
            ),
          ),
        );
        break;
      case 'copyid':
        Clipboard.setData(
          ClipboardData(text: product.productId),
        );
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Product ID is copied to clipboard.'),
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
                  onPressed: () async {
                    await Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).deleteProduct(
                      id: product.productId,
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
    final productsProvider = Provider.of<ProductProvider>(context);
    final categoriesProvider = Provider.of<CategoryProvider>(context);
    final productList = productsProvider.items;
    final categoryList = categoriesProvider.items;
    return Scaffold(
      drawer: MainDrawer(),
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
                productsProvider.enableSearch(value);
              },
            ),
          ),
          Text(
            'Note: Background color indicates the status of product.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 15),
              child: RefreshIndicator(
                onRefresh: () => getAllProducts(context),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Product prod = productList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              prod.status ? Colors.green[50] : Colors.red[50],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(prod.imageUrl),
                          ),
                          title: Text(prod.productName),
                          subtitle: Text(
                            categoryList
                                .firstWhere(
                                    (element) => element.id == prod.categoryId)
                                .name,
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              menuItemSelected(
                                value,
                                context,
                                product: prod,
                              );
                            },
                            itemBuilder: (context) => popupMenuList
                                .map(
                                  (menu) => PopupMenuItem(
                                    child: ListTile(
                                      leading: menu['icon'],
                                      title: Text(menu['name']),
                                      contentPadding: EdgeInsets.all(0),
                                    ),
                                    value: menu['value'],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                    itemCount: productList.length,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
