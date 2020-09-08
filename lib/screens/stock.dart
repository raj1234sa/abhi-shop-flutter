import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:abhi_shop/widgets/stock_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StockListScreen extends StatelessWidget {
  static final ROUTE_NAME = 'stock_list_screen';

  Future<void> refreshStock(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).setProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final productList = productProvider.items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Stock'),
      ),
      drawer: MainDrawer(),
      body: RefreshIndicator(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: ListView.builder(
            itemBuilder: (context, index) {
              Product prod = productList[index];
              return StockItem(
                product: prod,
              );
            },
            itemCount: productList.length,
          ),
        ),
        onRefresh: () => refreshStock(context),
      ),
    );
  }
}
