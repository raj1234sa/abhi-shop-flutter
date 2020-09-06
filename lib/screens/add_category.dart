import 'dart:io';

import 'package:abhi_shop/models/category.dart';
import 'package:abhi_shop/providers/category_provider.dart';
import 'package:abhi_shop/widgets/icon_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

final StorageReference storageReference = FirebaseStorage.instance.ref();

class AddCategoryScreen extends StatefulWidget {
  static final String ROUTE_NAME = "add_category_screen";
  Category editCategory;

  AddCategoryScreen({this.editCategory});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _categoryNameController = TextEditingController();
  final _catDescriptionController = TextEditingController();
  final _catDescriptionFNode = FocusNode();
  bool _catStatus = true;

  String _categoryId;
  String appHeading = '';

  File _imageFile;
  Directory tempDir;

  Future<void> _saveForm() async {
    bool validform = _formKey.currentState.validate();
    if (validform) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true;
      });
      final categoriesProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      String mediaUrl =
          await categoriesProvider.uploadImage(_imageFile, _categoryId);
      Category category = Category(
        id: _categoryId,
        name: _categoryNameController.text,
        imageUrl: mediaUrl,
        status: _catStatus,
        description: _catDescriptionController.text,
      );
      await categoriesProvider.addEditCategory(category: category);
      Toast.show(
        widget.editCategory == null
            ? 'Category is added!!'
            : 'Category is updated!!',
        context,
        duration: Toast.LENGTH_LONG + 5,
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageReference
        .child('categories')
        .child('category_$_categoryId.jpg')
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
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

  Future<File> convertUriToFile({String url}) async {
    File file = new File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
    http.Response response = await http.get(url);
    File networkImage = await file.writeAsBytes(response.bodyBytes);
    return networkImage;
  }

  Future<void> initializeData() async {
    tempDir = await getTemporaryDirectory();
    setState(() {
      appHeading =
          (widget.editCategory == null) ? 'Add Category' : 'Edit Category';
      _categoryId = widget.editCategory == null
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : widget.editCategory.id;
    });
    if (widget.editCategory != null) {
      setState(() {
        _isLoading = true;
      });
      _categoryNameController.text = widget.editCategory.name;
      _catDescriptionController.text = widget.editCategory.description;
      _catStatus = widget.editCategory.status;
      File tmpFile = await convertUriToFile(url: widget.editCategory.imageUrl);
      setState(() {
        if (tmpFile != null) {
          _imageFile = tmpFile;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _imageFile = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(appHeading),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
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
                        controller: _categoryNameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Category name is required.';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_catDescriptionFNode);
                        },
                      ),
                      TextFormField(
                        controller: _catDescriptionController,
                        focusNode: _catDescriptionFNode,
                        decoration: InputDecoration(
                          labelText: 'Product Description',
                        ),
                        maxLines: 5,
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                      ),
                      SwitchListTile(
                        value: _catStatus,
                        onChanged: (value) {
                          setState(() {
                            _catStatus = value;
                          });
                        },
                        title: Text('Status'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
