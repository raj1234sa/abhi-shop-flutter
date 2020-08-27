import 'dart:io';

import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/models/size_price.dart';
import 'package:abhi_shop/widgets/icon_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/product.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final StorageReference storageReference = FirebaseStorage.instance.ref();

class AddProductScreen extends StatefulWidget {
  static final ROUTE_NAME = 'add_product_screen';
  Product editProduct;

  AddProductScreen({this.editProduct});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _prodNameController = TextEditingController();

  bool _isHotProduct = false;
  bool _isNewArrival = true;

  String productId;

  File _imageFile;
  bool _loading = false;

  List<ProductSizePrice> _productSizePriceList = [
    ProductSizePrice(
      sizeNameController: TextEditingController(),
      sizePriceController: TextEditingController(),
      sizeNameFocusNode: FocusNode(),
      sizePriceFocusNode: FocusNode(),
    )
  ];

  List<dynamic> getSizePricesFromModel() {
    return _productSizePriceList
        .map((sizePrice) => {
              'size': sizePrice.sizeNameController.text,
              'price': sizePrice.sizePriceController.text,
            })
        .toList();
  }

  Future<void> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tempDir.path,
      quality: 88,
    );
    setState(() {
      _imageFile = result;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageReference
        .child('products')
        .child('product_$productId.jpg')
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  _saveForm(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    final isValidForm = _formKey.currentState.validate();
    if (isValidForm) {
      FocusScope.of(context).unfocus();
      compressImage(_imageFile);
      String mediaUrl = await uploadImage(_imageFile);
      Product product = Product(
        id: productId,
        productName: _prodNameController.text,
        sizePrices: getSizePricesFromModel(),
        isHotProduct: _isHotProduct,
        isNewArrival: _isNewArrival,
        imageUrl: mediaUrl,
      );
      await _firestore
          .collection('products')
          .doc(productId)
          .set(product.toJson());
      Toast.show(
        widget.editProduct == null
            ? 'Product is added!!'
            : 'Product is updated!!',
        context,
        duration: Toast.LENGTH_LONG + 5,
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _prodNameController.dispose();
    _imageFile = null;
    widget.editProduct = null;
    super.dispose();
  }

  Future<void> _takePicture(ImageSource type) async {
    final PickedFile image = await ImagePicker().getImage(
      source: type,
    );
    if (image != null) {
      final croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      );
      if (croppedImage != null) {
        print("Picked image path ${croppedImage.path}");
        setState(() {
          _imageFile = croppedImage;
        });
      }
    }
  }

  void showImagePickerOption(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 80,
              margin: EdgeInsets.all(25),
              child: Row(
                children: [
                  IconAvatar(
                    color: Colors.lightBlue,
                    icon: Icons.camera_alt,
                    name: 'Camera',
                    onPress: () {
                      Navigator.of(context).pop();
                      _takePicture(ImageSource.camera);
                    },
                  ),
                  IconAvatar(
                    color: Colors.teal,
                    icon: Icons.image,
                    name: 'Gallery',
                    onPress: () {
                      Navigator.of(context).pop();

                      _takePicture(ImageSource.gallery);
                    },
                  ),
                  IconAvatar(
                    color: Colors.redAccent,
                    icon: Icons.clear,
                    name: 'Clear',
                    onPress: () {
                      setState(() {
                        _imageFile = null;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    productId = widget.editProduct == null
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.editProduct.id;
    if (widget.editProduct != null) {
      setState(() {
        _loading = true;
      });
      _prodNameController.text = widget.editProduct.productName;
      _productSizePriceList = widget.editProduct.sizePrices
          .map(
            (sizePriceJson) => ProductSizePrice.fromJSON(sizePriceJson),
          )
          .toList();
      _isHotProduct = widget.editProduct.isHotProduct;
      _isNewArrival = widget.editProduct.isNewArrival;
      convertUriToFile(url: widget.editProduct.imageUrl).then((value) {
        setState(() {
          _imageFile = value;
          _loading = false;
        });
      });
    }
    super.initState();
  }

  Future<File> convertUriToFile({String url}) async {
    Directory tempDir = await getTemporaryDirectory();
    File file = new File('${tempDir.path}/${widget.editProduct.id}.jpg');
    http.Response response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm(context);
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  children: <Widget>[
                    InkWell(
                      onTap: () => showImagePickerOption(context),
                      child: Container(
                        alignment: Alignment.center,
                        width: width,
                        height: width - 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: _imageFile == null
                            ? Icon(
                                Icons.add_circle,
                                size: 50.0,
                                color: Colors.blue,
                              )
                            : Image.file(
                                _imageFile,
                                width: width,
                                height: width - 15,
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                    TextFormField(
                      controller: _prodNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Product name is required.';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(
                            _productSizePriceList[0].sizeNameFocusNode);
                      },
                    ),
                    ..._productSizePriceList.map((productSizePrice) {
                      int index =
                          _productSizePriceList.indexOf(productSizePrice);
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: productSizePrice.sizeNameController,
                              decoration: InputDecoration(
                                labelText: 'Product Size',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Product size is required.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(
                                    productSizePrice.sizePriceFocusNode);
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: productSizePrice.sizeNameFocusNode,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: productSizePrice.sizePriceController,
                              decoration: InputDecoration(
                                labelText: 'Product Price',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Product price is required.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(
                                    _productSizePriceList[index + 1]
                                        .sizeNameFocusNode);
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: productSizePrice.sizePriceFocusNode,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (_productSizePriceList.length > 1)
                            GestureDetector(
                              child: Icon(
                                Icons.delete,
                              ),
                              onTap: () {
                                setState(() {
                                  _productSizePriceList.removeAt(index);
                                });
                              },
                            ),
                        ],
                      );
                    }),
                    RaisedButton.icon(
                      onPressed: () {
                        setState(() {
                          _productSizePriceList.add(ProductSizePrice(
                            sizeNameController: TextEditingController(),
                            sizePriceController: TextEditingController(),
                            sizeNameFocusNode: FocusNode(),
                            sizePriceFocusNode: FocusNode(),
                          ));
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Size'),
                    ),
                    SwitchListTile(
                      value: _isHotProduct,
                      onChanged: (value) {
                        setState(() {
                          _isHotProduct = value;
                        });
                      },
                      title: Text('Hot Product'),
                    ),
                    SwitchListTile(
                      value: _isNewArrival,
                      onChanged: (value) {
                        setState(() {
                          _isNewArrival = value;
                        });
                      },
                      title: Text('New Arrival'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
