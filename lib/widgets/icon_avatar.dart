import 'package:flutter/material.dart';

class IconAvatar extends StatelessWidget {
  final Function onPress;
  final IconData icon;
  final String name;
  final Color color;

  IconAvatar({
    this.onPress,
    this.name,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 25,
            child: IconButton(
              color: Colors.white,
              icon: Icon(icon),
              onPressed: onPress,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(name),
        ],
      ),
    );
  }
}
