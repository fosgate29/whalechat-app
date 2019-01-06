import 'package:flutter/material.dart';

class YesNoDialog {
  static AlertDialog build({
    @required BuildContext context,
    @required String title,
    @required String content,
    @required VoidCallback onYes,
    @required VoidCallback onNo,
    String yesLabel = "Yes",
    String noLabel = "No"
  }) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(child: Text(noLabel), onPressed: () {
          onNo();
          Navigator.of(context, rootNavigator: true).pop();
        }),
        FlatButton(child: Text(yesLabel), onPressed: () {
          onYes();
          Navigator.of(context, rootNavigator: true).pop();
        })
      ]
    );
  }
}
