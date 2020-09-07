import 'dart:math';

import 'package:abhi_shop/models/product.dart';
import 'package:flutter/material.dart';

class StockItem extends StatefulWidget {
  final stockData;
  final Product product;
  StockItem({@required this.stockData, this.product});
  @override
  _StockItemState createState() => _StockItemState();
}

class _StockItemState extends State<StockItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final stockData = widget.stockData;
    final Product product = widget.product;
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
          if (_expanded)
            Container(
              height: stockData.length * 60.0,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var stock = stockData[index];
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
                                stock['size'],
                              ),
                              Text(
                                "Remaining Stock: ${stock['stock'] ?? 0}",
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
                              print('edit');
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: stockData.length,
              ),
            ),
        ],
      ),
    );
  }
}
