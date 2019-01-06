import 'package:flutter/material.dart';
import 'package:whalechat_app/utils/app_state.dart';

class EditProfileScreen extends StatelessWidget {
  final _nicknameController = TextEditingController(
    text: AppState.instance.storage.nickname);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings > Profile")),
      body: Form(child: Padding(padding: EdgeInsets.all(24.0), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nickname"),
          TextFormField(controller: _nicknameController, enabled: false),
        ]))
      )
    );
  }

  void save(BuildContext context) {
    AppState.instance.storage.nickname = _nicknameController.value.text;
    Navigator.pop(context);
  }
}
