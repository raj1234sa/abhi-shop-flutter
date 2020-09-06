import 'dart:io';

import 'package:abhi_shop/models/category.dart';
import 'package:abhi_shop/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class CategoryProvider with ChangeNotifier {
  static List<Category> _categories = [];
  List<Product> _products = [];

  List<Category> get items {
    return _categories;
  }

  static Future<void> initCategories() async {
    final CollectionReference _categoriesRef =
        FirebaseFirestore.instance.collection('categories');
    QuerySnapshot catsnapshot = await _categoriesRef.get();
    List<Category> list = [];
    catsnapshot.docs.forEach((element) {
      list.add(Category.fromJson(element));
    });
    _categories = list;
  }

  List<Category> get activeItems {
    return _categories.where((element) => element.status);
  }

  List<Category> get inactiveItems {
    return _categories.where((element) => !element.status);
  }

  Future<void> setCategories() async {
    final CollectionReference _categoriesRef =
        FirebaseFirestore.instance.collection('categories');
    QuerySnapshot catsnapshot = await _categoriesRef.get();
    List<Category> list = [];
    catsnapshot.docs.forEach((element) {
      list.add(Category.fromJson(element));
    });
    _categories = list;
    notifyListeners();
  }

  Category getCategoryData({@required id}) {
    return _categories.firstWhere((element) => element.id == id);
  }

  Future<void> addEditCategory({@required Category category}) async {
    CollectionReference _categoriesRef =
        FirebaseFirestore.instance.collection('categories');
    await _categoriesRef.doc(category.id).set(category.toJson());
    await setCategories();
  }

  Future<String> uploadImage(File imageFile, String categoryId) async {
    final StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageUploadTask uploadTask = storageReference
        .child('categories')
        .child('category_$categoryId.jpg')
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteCategory({@required id}) async {
    CollectionReference _categoriesRef =
        FirebaseFirestore.instance.collection('categories');
    StorageReference storageReference = FirebaseStorage.instance.ref();
    _categoriesRef
        .doc(
          id,
        )
        .delete()
        .then((value) async {
      await storageReference.child('categories/category_$id.jpg').delete();
    });
    await setCategories();
  }
}
