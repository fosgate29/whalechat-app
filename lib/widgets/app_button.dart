import 'package:flutter/material.dart';

class AppButton {
  static Widget buildBig(BuildContext context, String text, {VoidCallback onPressed, double horizontalInset = 0, IconData icon}) {
    return Row(children: [Expanded(child: Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: horizontalInset),
      child: build(context, text, onPressed:  onPressed, icon: icon, verticalPadding: 16)
    ))]);
  }

  static RaisedButton build(BuildContext context, String text, {VoidCallback onPressed, IconData icon, double verticalPadding: 0}) {
    final cs = Theme.of(context).buttonTheme.colorScheme;

    if (icon == null) {
      return RaisedButton(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Text(text),
        color: cs.primary,
        textColor: cs.onPrimary,
        onPressed: onPressed,
      );
    } else {
      return RaisedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        color: cs.primary,
        textColor: cs.onPrimary,
      );
    }
  }
}
