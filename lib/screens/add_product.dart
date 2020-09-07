import 'dart:io';

import 'package:abhi_shop/models/category.dart';
import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/models/size_price.dart';
import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:abhi_shop/widgets/icon_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddProductScreen extends StatefulWidget {
  static final ROUTE_NAME = 'add_product_screen';
  Product editProduct;

  AddProductScreen({this.editProduct});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final _formKey = GlobalKey<FormState>();

  final _prodNameController = TextEditingController();
  final _prodDescriptionController = TextEditingController();
  final _prodDescriptionFNode = FocusNode();

  bool _isHotProduct = false;
  bool _isNewArrival = true;
  bool _prodStatus = true;

  String _productId;

  File _imageFile;
  bool _loading = false;
  Directory tempDir;
  String appHeading;
  var _selectedCategory;
  var _selectedPriceMethod;

  List<DropdownMenuItem> _categoriesList = [];
  List<DropdownMenuItem> _priceMethodList = [
    DropdownMenuItem(
      child: Text('Per Piece'),
      value: 'Per Piece',
    ),
    DropdownMenuItem(
      child: Text('Per Kilogram'),
      value: 'Per Kilogram',
    ),
    DropdownMenuItem(
      child: Text('Per Dozen'),
      value: 'Per Dozen',
    ),
  ];

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

  Future<void> _saveForm(BuildContext context) async {
    final productsProvider =
        Provider.of<ProductProvider>(context, listen: false);
    setState(() {
      _loading = true;
    });
    final isValidForm = _formKey.currentState.validate();
    if (isValidForm) {
      FocusScope.of(context).unfocus();
      // await compressImage(_imageFile);
      String mediaUrl =
          await productsProvider.uploadImage(_imageFile, _productId);
      Product product = Product(
        id: _productId,
        productName: _prodNameController.text,
        sizePrices: getSizePricesFromModel(),
        isHotProduct: _isHotProduct,
        isNewArrival: _isNewArrival,
        imageUrl: mediaUrl,
        categoryId: _selectedCategory,
        status: _prodStatus,
        description: _prodDescriptionController.text,
        priceMethod: _selectedPriceMethod,
      );
      bool add = widget.editProduct == null ? true : false;
      productsProvider.addEditProduct(
        product: product,
        addMode: add,
      );
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

  Future<void> getCategory() async {
    List<Category> cats = Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).items;
    setState(() {
      _categoriesList = cats.map((cat) {
        return DropdownMenuItem(
          child: Text(cat.name),
          value: cat.id,
        );
      }).toList();
      _selectedCategory = widget.editProduct == null
          ? _categoriesList[0].value
          : widget.editProduct.categoryId;
    });
  }

  @override
  void dispose() {
    _prodNameController.dispose();
    _imageFile = null;
    widget.editProduct = null;
    tempDir.delete(recursive: true);
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
      },
    );
  }

  Future<void> initializeData() async {
    tempDir = await getTemporaryDirectory();
    _productId = widget.editProduct == null
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.editProduct.id;
    _selectedPriceMethod = (widget.editProduct == null)
        ? _priceMethodList[0].value
        : widget.editProduct.priceMethod;
    if (widget.editProduct != null) {
      setState(() {
        _loading = true;
      });
      _prodNameController.text = widget.editProduct.productName;
      _prodDescriptionController.text = widget.editProduct.description;
      _productSizePriceList = widget.editProduct.sizePrices
          .map(
            (sizePriceJson) => ProductSizePrice.fromJSON(sizePriceJson),
          )
          .toList();
      _isHotProduct = widget.editProduct.isHotProduct;
      _isNewArrival = widget.editProduct.isNewArrival;
      _prodStatus = widget.editProduct.status;
      File _fileImage =
          await convertUriToFile(url: widget.editProduct.imageUrl);
      if (_fileImage != null) {
        print('this is file image : ${_fileImage.path}');
        setState(() {
          _imageFile = _fileImage;
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getCategory();
    initializeData();
    super.initState();
  }

  Future<File> convertUriToFile({String url}) async {
    File file = new File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
    http.Response response = await http.get(url);
    File networkImage = await file.writeAsBytes(response.bodyBytes);
    return networkImage;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:
            Text((widget.editProduct == null) ? 'Add Product' : 'Edit Product'),
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
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Product Category',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          DropdownButton(
                            items: _categoriesList,
                            value: _selectedCategory,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ],
                      ),
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
                                    (index + 1) == _productSizePriceList.length
                                        ? _prodDescriptionFNode
                                        : _productSizePriceList[index + 1]
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
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pricing Method',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          DropdownButton(
                            items: _priceMethodList,
                            value: _selectedPriceMethod,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedPriceMethod = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _prodDescriptionController,
                      focusNode: _prodDescriptionFNode,
                      decoration: InputDecoration(
                        labelText: 'Product Description',
                      ),
                      maxLines: 5,
                    ),
                    SwitchListTile(
                      value: _prodStatus,
                      onChanged: (value) {
                        setState(() {
                          _prodStatus = value;
                        });
                      },
                      title: Text('Status'),
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
