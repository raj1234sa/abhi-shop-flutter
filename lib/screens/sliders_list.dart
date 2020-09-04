import 'package:abhi_shop/screens/add_slider.dart';
import 'package:abhi_shop/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:abhi_shop/models/slider.dart' as slider;

class SlidersListScreen extends StatefulWidget {
  static const ROUTE_NAME = 'sliders_list_screen';
  @override
  _SlidersListScreenState createState() => _SlidersListScreenState();
}

class _SlidersListScreenState extends State<SlidersListScreen> {
  StorageReference storageReference = FirebaseStorage.instance.ref();
  CollectionReference _sliderRef =
      FirebaseFirestore.instance.collection('sliders');
  bool _isLoading = true;
  List<slider.Slider> _slidersList = [];

  Future<void> getAllSliders() async {
    _sliderRef.get().then((value) {
      setState(() {
        _slidersList =
            value.docs.map((e) => slider.Slider.fromJson(e)).toList();
      });
    }).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getAllSliders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => getAllSliders(),
              child: Container(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(_slidersList[index].imageUrl),
                      ),
                      title: Text(_slidersList[index].name),
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
                                      editSlider: _slidersList[index],
                                    ),
                                  ),
                                );
                                getAllSliders();
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
                                            String sliderId =
                                                _slidersList[index].id;
                                            _sliderRef
                                                .doc(
                                                  sliderId,
                                                )
                                                .delete()
                                                .then((value) async {
                                              await storageReference
                                                  .child(
                                                      'sliders/slider_$sliderId.jpg')
                                                  .delete();
                                              setState(() {
                                                _sliderRef = FirebaseFirestore
                                                    .instance
                                                    .collection('sliders');
                                                getAllSliders();
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
                  itemCount: _slidersList.length,
                ),
              ),
            ),
    );
  }
}
