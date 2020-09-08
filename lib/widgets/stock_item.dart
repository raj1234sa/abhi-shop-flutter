import 'package:abhi_shop/models/product.dart';
import 'package:abhi_shop/models/size_price.dart';
import 'package:abhi_shop/models/stock.dart';
import 'package:abhi_shop/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class StockItem extends StatefulWidget {
  final Product product;
  StockItem({this.product});
  @override
  _StockItemState createState() => _StockItemState();
}

class _StockItemState extends State<StockItem> {
  bool _expanded = false;
  final _formKey = GlobalKey<FormState>();
  String _productId;
  int _stockListId;
  String _modeSeletced;

  final _stockController = TextEditingController();
  final List<DropdownMenuItem> _addDebitList = [
    DropdownMenuItem(
      child: Text('Credit'),
      value: '+',
    ),
    DropdownMenuItem(
      child: Text('Debit'),
      value: '-',
    ),
  ];

  Future<void> _saveForm(BuildContext context) async {
    final formValid = _formKey.currentState.validate();
    if (formValid) {
      Provider.of<ProductProvider>(context, listen: false)
          .manageStock(
        amount: _stockController.text,
        stockId: _stockListId,
        productId: _productId,
        mode: _modeSeletced,
      )
          .then((value) {
        if (value != null) {
          Toast.show(value[0], context,
              backgroundColor: value[1], duration: Toast.LENGTH_LONG + 2);
        } else {
          Toast.show('Stock is updated successfully!!', context,
              backgroundColor: Colors.green, duration: Toast.LENGTH_LONG + 2);
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void initState() {
    setState(() {
      _modeSeletced = _addDebitList[0].value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final Stock stockObj = Provider.of<ProductProvider>(context)
        .getStockData(productId: product.id);
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(product.productName),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded) Divider(),
          if (_expanded && stockObj != null)
            Container(
              height: stockObj.stockData.length * 60.0,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var stock = stockObj.stockData[index];
                  String stockamount = stock['$index'].toString() ?? '0';
                  List<dynamic> sizePrice = product.sizePrices;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                sizePrice[index]['size'],
                              ),
                              Text(
                                "Remaining Stock: ${stockamount ?? 0}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            child: Icon(Icons.edit),
                            onTap: () {
                              setState(() {
                                _productId = product.id;
                                _stockListId = index;
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    title: Text(
                                      'Credit/Debit Stock',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(30),
                                    children: <Widget>[
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            TextFormField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Stock Amount',
                                              ),
                                              controller: _stockController,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Stock amount is required.';
                                                }
                                                return null;
                                              },
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Text(
                                                'Select One of the operation',
                                              ),
                                            ),
                                            DropdownButton(
                                              isExpanded: true,
                                              value: _modeSeletced,
                                              items: _addDebitList,
                                              onChanged: (value) {
                                                setState(() {
                                                  _modeSeletced = value;
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: RaisedButton.icon(
                                                onPressed: () async {
                                                  await _saveForm(context);
                                                },
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                icon: Icon(
                                                  Icons.save,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: stockObj.stockData.length,
              ),
            ),
        ],
      ),
    );
  }
}
