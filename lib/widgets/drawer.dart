import 'package:abhi_shop/screens/category_list.dart';
import 'package:abhi_shop/screens/products_list.dart';
import 'package:abhi_shop/screens/sliders_list.dart';
import 'package:abhi_shop/screens/stock.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                title: Text('Categories'),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context)
                      .pushReplacementNamed(CategoryListScreen.ROUTE_NAME);
                },
              ),
              ListTile(
                title: Text('Slider'),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context)
                      .pushReplacementNamed(SlidersListScreen.ROUTE_NAME);
                },
              ),
              ListTile(
                title: Text('Stocks'),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context)
                      .pushReplacementNamed(StockListScreen.ROUTE_NAME);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
