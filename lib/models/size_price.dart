import 'package:flutter/material.dart';

class ProductSizePrice {
  final TextEditingController sizeNameController;
  final TextEditingController sizePriceController;
  final FocusNode sizeNameFocusNode;
  final FocusNode sizePriceFocusNode;
  int stock;

  ProductSizePrice({
    @required this.sizeNameController,
    @required this.sizePriceController,
    @required this.sizeNameFocusNode,
    @required this.sizePriceFocusNode,
    this.stock,
  });

  factory ProductSizePrice.fromJSON(Map data) {
    TextEditingController nameController =
        TextEditingController(text: data['size'] ?? '');
    TextEditingController priceController =
        TextEditingController(text: data['price'] ?? '');
    return ProductSizePrice(
      sizeNameController: nameController,
      sizePriceController: priceController,
      sizeNameFocusNode: FocusNode(),
      sizePriceFocusNode: FocusNode(),
      stock: data['stock'],
    );
  }
}
