import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/providers/slider_provider.dart';
import 'package:abhi_shop/screens/add_category.dart';
import 'package:abhi_shop/screens/add_product.dart';
import 'package:abhi_shop/screens/add_slider.dart';
import 'package:abhi_shop/screens/category_list.dart';
import 'package:abhi_shop/screens/products_list.dart';
import 'package:abhi_shop/screens/sliders_list.dart';
import 'package:abhi_shop/screens/stock.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ProductProvider.initProducts();
  await CategoryProvider.initCategories();
  await SliderProvider.initSliders();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SliderProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: ProductListScreen.ROUTE_NAME,
        routes: {
          ProductListScreen.ROUTE_NAME: (context) => ProductListScreen(),
          AddProductScreen.ROUTE_NAME: (context) => AddProductScreen(),
          CategoryListScreen.ROUTE_NAME: (context) => CategoryListScreen(),
          AddCategoryScreen.ROUTE_NAME: (context) => AddCategoryScreen(),
          SlidersListScreen.ROUTE_NAME: (context) => SlidersListScreen(),
          AddSliderScreen.ROUTE_NAME: (context) => AddSliderScreen(),
          StockListScreen.ROUTE_NAME: (context) => StockListScreen(),
        },
      ),
    );
  }
}
