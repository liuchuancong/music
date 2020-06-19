import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class Button extends StatelessWidget {
  final IconData icon;
  final Function onPressed;
  const Button({Key key, this.icon, this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.all(8),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: Icon(
        icon,
        color: NeumorphicTheme.isUsingDark(context)
            ? Colors.white70
            : Colors.black87,
      ),
      onPressed: onPressed,
    );
  }
}


