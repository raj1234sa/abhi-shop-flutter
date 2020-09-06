import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/providers/slider_provider.dart';
import 'package:abhi_shop/screens/add_slider.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abhi_shop/models/slider.dart' as slider;

class SlidersListScreen extends StatelessWidget {
  static const ROUTE_NAME = 'sliders_list_screen';

  Future<void> getAllSliders(BuildContext context) async {
    Provider.of<SliderProvider>(
      context,
      listen: false,
    ).setSliders();
  }

  @override
  Widget build(BuildContext context) {
    final slidersProvider = Provider.of<SliderProvider>(context);
    final categoriesProvider = Provider.of<CategoryProvider>(context);
    final productsProvider = Provider.of<ProductProvider>(context);
    List<slider.Slider> sliderList = slidersProvider.items;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddSliderScreen.ROUTE_NAME);
            },
          ),
        ],
        title: Text('Sliders List'),
      ),
      body: RefreshIndicator(
        onRefresh: () => getAllSliders(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: ListView.builder(
            itemBuilder: (context, index) {
              slider.Slider slid = sliderList[index];
              final splitArr = slid.sliderFor.split('_');
              String subtitle = splitArr[0] == 'p'
                  ? 'Product: ' +
                      productsProvider
                          .getProductData(id: splitArr[1])
                          .productName
                  : 'Category: ' +
                      categoriesProvider.getCategoryData(id: splitArr[1]).name;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(slid.imageUrl),
                ),
                title: Text(slid.name),
                subtitle: Text(subtitle),
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
                              builder: (context) => AddSliderScreen(
                                editSlider: slid,
                              ),
                            ),
                          );
                          getAllSliders(context);
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
                                  'Are you sure to delete the slider??',
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
                                      slidersProvider.deleteSlider(id: slid.id);
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: sliderList.length,
          ),
        ),
      ),
    );
  }
}
