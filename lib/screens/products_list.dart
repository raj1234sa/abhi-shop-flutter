import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProductListScreen extends StatelessWidget {
  static final ROUTE_NAME = 'products_list_screen';
  final _productSearchController = TextEditingController();

  Future<void> getAllProducts(BuildContext context) async {
    Provider.of<ProductProvider>(context, listen: false).setProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductProvider>(context);
    final categoriesProvider = Provider.of<CategoryProvider>(context);
    productsProvider.setProducts();
    categoriesProvider.setCategories();
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => getAllProducts(context),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    Product prod = productList[index];
                    return ListTile(
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
                      trailing: Container(
                        width: MediaQuery.of(context).size.width * .41,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Copy ID',
                              icon: Icon(Icons.content_copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: prod.id),
                                );
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Product ID is copied to clipboard.'),
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
                                    builder: (context) => AddProductScreen(
                                      editProduct: prod,
                                    ),
                                  ),
                                );
                                getAllProducts(context);
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
                                        'Are you sure to delete the ${prod.productName} ?',
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
                                            await productsProvider
                                                .deleteProduct(id: prod.id);
                                            Navigator.of(context).pop();
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
                  itemCount: productList.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
