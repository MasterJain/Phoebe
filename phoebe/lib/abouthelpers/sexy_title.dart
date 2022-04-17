
import 'package:flutter/material.dart';
import 'ui_helpers.dart';

class SexyTile extends StatelessWidget {
  const SexyTile({
    this.child,
    this.color,
    this.splashColor,
    this.onTap,
  });
  final Widget child;
  final Color color;
  final Color splashColor;
  final Function() onTap;

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Material(
        color: color,
        elevation: 10.0,
        borderRadius: BorderRadius.circular(15.0),
        shadowColor: Colors.transparent,
        child: InkWell(
          child: child,
          splashColor: splashColor,
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap == null ? doNothing : () => onTap(),
        ),
      ),
    );
  }
}