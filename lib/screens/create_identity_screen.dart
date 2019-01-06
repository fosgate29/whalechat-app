import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:whalechat_app/screens/chat_list_screen.dart';
import 'package:whalechat_app/utils/crypto_utils.dart';
import 'package:whalechat_app/widgets/app_button.dart';
import 'package:whalechat_app/widgets/flexible_scroll_view.dart';
import 'package:whalechat_app/utils/app_state.dart';

class CreateIdentityScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen> {
  var _privKey = AppState.instance.secretKey;
  var _nicknameController = TextEditingController();
  var _seedPhraseController = TextEditingController(text: "Loading...");
  var _pubKeyController = TextEditingController(text: "Loading...");
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    AppState.instance.generateNewIdentity().then((_) {
      setState(() { this._update(); });
    });
  }

  Future _update() async {
    _privKey = AppState.instance.secretKey;
    _nicknameController.text = AppState.instance.storage.nickname;
    var resp = await AppState.instance.httpClient.get(BIP39_ENGLISH_WORDLIST_URL);
    final wordlist = resp.body.trim().split("\n");
    _seedPhraseController.text = mnemonicFromPrivateKey(wordlist, _privKey).join(" ");
    _pubKeyController.text = AppState.instance.publicKey;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create identity')),
      body: FlexibleScrollView.build(
        context: context,
        child: Form(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Identity Recovery Phrase", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _seedPhraseController,
              enabled: false,
              maxLines: 4,
            ),

            Text("Note: Save this phrase in an off-line secure place.", style: TextStyle(fontWeight: FontWeight.w300)),
            SizedBox(height: 16),
            Text("Public Key", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _pubKeyController,
              enabled: false,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            Text("Nickname", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _nicknameController,
            ),

            SizedBox(height: 16),

            AppButton.build(context, "Generate new identity", onPressed: () {
              setState(() {
                _seedPhraseController.text = 'Loading...';
                _pubKeyController.text = 'Loading...';
                _loading = true;
                AppState.instance.generateNewIdentity().then((_) =>
                  setState(() {
                    this._update();
                    _loading = false;
                  })
                );
              });
            }, icon: Icons.refresh),

            Spacer(),

            AppButton.buildBig(context, "Finish", onPressed: _loading ? null : () async {
              AppState.instance.storage.nickname = _nicknameController.value.text;

              await AppState.instance.apiService.register(
                AppState.instance.storage.nickname,
                AppState.instance.publicKey,
                hex.encode(AppState.instance.chatKeyPair.publicKey),
              );

              await AppState.instance.storage.save();

              Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => ChatListScreen()), (_) => false);
            })
          ],
        ))
      )
    );
  }
}
