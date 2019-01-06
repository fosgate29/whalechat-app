import 'package:flutter/material.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/app_button.dart';
import 'package:whalechat_app/screens/chat_list_screen.dart';
import 'package:whalechat_app/utils/crypto_utils.dart';

class ImportIdentityScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImportIdentityScreenState();
}

class _ImportIdentityScreenState extends State<ImportIdentityScreen> {
  final _seedPhraseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Import Identity")),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Form(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Identity Recovery Phrase"),

            TextFormField(
              controller: _seedPhraseController,
              maxLines: 4,
            ),

            Spacer(),

            AppButton.buildBig(context, "Import", onPressed: () => _importIdentity(context))
          ]))
      )
    );
  }

  _importIdentity(BuildContext context) async {
    final wordlist = (await AppState.instance.httpClient.get(
      BIP39_ENGLISH_WORDLIST_URL
    )).body.trim().split("\n");

    AppState.instance.secretKey = mnemonicToPrivateKey(
      wordlist, _seedPhraseController.value.text.trim().split(" "));

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => ChatListScreen()
    ));
  }
}

