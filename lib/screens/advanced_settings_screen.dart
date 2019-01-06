import 'package:flutter/material.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/app_button.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  final _whisperServerUrl = TextEditingController(
    text: AppState.instance.shhRpcServerUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings > Advanced")),
      body: Form(child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Whisper server address"),
            TextFormField(controller: _whisperServerUrl),
            Spacer(),
            AppButton.buildBig(context, "Save", onPressed: () => save(context))
          ]))
      )
    );
  }

  void save(BuildContext context) {
    AppState.instance.shhRpcServerUrl = _whisperServerUrl.value.text;
    Navigator.pop(context);
  }
}
