import 'dart:io';

import 'package:abhi_shop/models/slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class SliderProvider with ChangeNotifier {
  static List<Slider> _sliders = [];

  List<Slider> get items {
    return _sliders;
  }

  static Future<void> initSliders() async {
    final CollectionReference _slidersRef =
        FirebaseFirestore.instance.collection('sliders');
    QuerySnapshot slidersnapshot = await _slidersRef.get();
    List<Slider> list = [];
    slidersnapshot.docs.forEach((element) {
      list.add(Slider.fromJson(element));
    });
    _sliders = list;
  }

  Future<void> setSliders() async {
    final CollectionReference _slidersRef =
        FirebaseFirestore.instance.collection('sliders');
    QuerySnapshot slidersnapshot = await _slidersRef.get();
    List<Slider> list = [];
    slidersnapshot.docs.forEach((element) {
      list.add(Slider.fromJson(element));
    });
    _sliders = list;
    notifyListeners();
  }

  Slider getSliderData({@required id}) {
    return _sliders.firstWhere((element) => element.id == id);
  }

  Future<void> addEditSlider({@required Slider slider}) async {
    CollectionReference _slidersRef =
        FirebaseFirestore.instance.collection('sliders');
    await _slidersRef.doc(slider.id).set(slider.toJson());
    await setSliders();
  }

  Future<String> uploadImage(File imageFile, String sliderId) async {
    final StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask = storageReference
        .child('sliders')
        .child('slider_$sliderId.jpg')
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteSlider({@required id}) async {
    CollectionReference _categoriesRef =
        FirebaseFirestore.instance.collection('sliders');
    StorageReference storageReference = FirebaseStorage.instance.ref();
    _categoriesRef
        .doc(
          id,
        )
        .delete()
        .then((value) async {
      await storageReference.child('sliders/slider_$id.jpg').delete();
    });
    await setSliders();
  }
}
