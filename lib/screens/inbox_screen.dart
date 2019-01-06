import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inbox"),),

      body: ListView(children: List.generate(5, (i) =>
        ListTile(
          title: Text('pizza'),
          trailing: Text("${i}h ago"),
          onTap: () => null,
        )
      ))
    );
  }
}
