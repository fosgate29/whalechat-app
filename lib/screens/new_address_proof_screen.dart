import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whalechat_app/screens/new_address_proof_screen_2.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/utils/utils.dart';
import 'package:whalechat_app/widgets/app_button.dart';
import 'package:whalechat_app/widgets/flexible_scroll_view.dart';

String messageToSign() {
  return '{"application": "wc", "version": "1", "pubKey": "' + AppState.instance.publicKey + '"}';
}

class NewAddressProofScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewAddressProofScreenState();
}

class _NewAddressProofScreenState extends State<NewAddressProofScreen> {
  String _selectedCurrency;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.title.copyWith(color: Colors.black45);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("Add Proof of Wallet Ownership")),
        body: FlexibleScrollView.build(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. Select Currency", style: title),
              SizedBox(height: 8),
              DropdownButton(
                value: _selectedCurrency,
                items: ['Bitcoin - BTC', 'Ethereum - ETH'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                onChanged: (ccy) {
                  setState(() {
                    _selectedCurrency = ccy;
                    _messageController.text = messageToSign();
                  });
                },
              ),
              Divider(),
              Text("2. Copy Message To Sign", style: title),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
                maxLines: 5,
                controller: _messageController,
              ),
              Row(children: [
                AppButton.build(context, "Copy", icon: Icons.content_copy, onPressed: () {
                  Clipboard.setData(ClipboardData(text: messageToSign()));
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("Message was copied to clipboard"),
                  ));
                }),
              ]),
              Divider(),
              Text("Copy the message to a wallet application that supports message signing and sign the message with your rich wallet. Then tap on Next to continue.", style: TextStyle(fontSize: 15.0)),
              Divider(),
              FlatButton(
                  child: Text('I need help'),
                  textColor: Colors.blue,
                  onPressed: () {
                    launchBrowser('https://github.com/whalechat');
                  }),
              Spacer(),
              AppButton.buildBig(context, "Next", onPressed: _next)
            ],
          ),
        ));
  }

  Future<void> _next() async {
    if (_selectedCurrency == null) {
      Fluttertoast.showToast(msg: "Please select a currency", gravity: ToastGravity.CENTER, backgroundColor: Color(0xff444444), textColor: Colors.white);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => NewAddressProofScreen2(_selectedCurrency.substring(_selectedCurrency.length - 3, _selectedCurrency.length))));
  }
}
