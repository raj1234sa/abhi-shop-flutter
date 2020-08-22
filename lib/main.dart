import 'package:abhi_shop/screens/add_product.dart';
import 'package:abhi_shop/screens/products_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: ProductListScreen.ROUTE_NAME,
      routes: {
        ProductListScreen.ROUTE_NAME: (context) => ProductListScreen(),
        AddProductScreen.ROUTE_NAME: (context) => AddProductScreen(),
      },
    );
  }
}
