import 'dart:io';

import 'package:abhi_shop/models/slider.dart' as slider;
import 'package:abhi_shop/widgets/icon_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';

class AddSliderScreen extends StatefulWidget {
  static const ROUTE_NAME = 'add_slider_screen';
  slider.Slider editSlider;
  AddSliderScreen({this.editSlider});
  @override
  _AddSliderScreenState createState() => _AddSliderScreenState();
}

class _AddSliderScreenState extends State<AddSliderScreen> {
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  CollectionReference _sliderRef =
      FirebaseFirestore.instance.collection('sliders');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _sliderId;
  File _imageFile;
  Directory tempDir;

  TextEditingController nameController = TextEditingController();

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageReference
        .child('sliders')
        .child('slider_$_sliderId.jpg')
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

  Future<void> _saveForm(BuildContext context) async {
    if (_imageFile == null) {
      Toast.show(
        'Image must be uploaded',
        context,
        duration: Toast.LENGTH_LONG + 3,
        backgroundColor: Colors.red,
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    String imageUrl = await uploadImage(_imageFile);
    slider.Slider sliderObj = slider.Slider(
      id: _sliderId,
      imageUrl: imageUrl,
      name: nameController.text,
    );
    await _sliderRef.doc(_sliderId).set(sliderObj.toJson());
    Toast.show(
      widget.editSlider == null ? 'Slider is added!!' : 'Slider is updated!!',
      context,
      duration: Toast.LENGTH_LONG + 5,
      backgroundColor: Colors.green,
    );
    Navigator.pop(context);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> initializeData() async {
    setState(() {
      _isLoading = true;
    });
    _sliderId = widget.editSlider == null
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.editSlider.id;
    if (widget.editSlider != null) {
      tempDir = await getTemporaryDirectory();
      File image = await convertUriToFile(url: widget.editSlider.imageUrl);
      _imageFile = image;
      nameController.text = widget.editSlider.name;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editSlider == null ? 'Add Sldier' : 'Edit Slider'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
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
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        _saveForm(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
