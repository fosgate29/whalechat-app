import 'package:flutter/material.dart';

class OkDialog {
  static AlertDialog build({
    @required BuildContext context,
    @required String title,
    @required String content,
    @required VoidCallback onOk,
    String okLabel = "OK"
    }) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(child: Text(okLabel), onPressed: () {
          onOk();
          Navigator.of(context).pop();
        }),
      ]
    );
  }
}
