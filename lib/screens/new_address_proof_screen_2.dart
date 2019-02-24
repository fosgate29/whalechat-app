import 'dart:convert';
import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whalechat_app/protocol/transport.dart';
import 'package:whalechat_app/screens/address_proof_list_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/utils/utils.dart';
import 'package:whalechat_app/widgets/app_button.dart';
import 'package:whalechat_app/widgets/flexible_scroll_view.dart';
import 'package:whalechat_app/screens/new_address_proof_screen.dart';

class NewAddressProofScreen2 extends StatefulWidget {
  final String selectedCurrency;

  NewAddressProofScreen2(this.selectedCurrency) : super();

  @override
  State<StatefulWidget> createState() => _NewAddressProofScreenState2(this.selectedCurrency);
}

class _NewAddressProofScreenState2 extends State<NewAddressProofScreen2> {
  final String _selectedCurrency;
  final _assetProofController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _addressController = TextEditingController();
  final _signatureController = TextEditingController();

  _NewAddressProofScreenState2(this._selectedCurrency) : super();

  @override
  void initState() {
    super.initState();

    _addressController.addListener(_updateProof);
    _signatureController.addListener(_updateProof);
  }

  void _updateProof() {
    if (_selectedCurrency.contains('BTC')) {
      setState(() {
        _assetProofController.text = [
          '-----BEGIN BITCOIN SIGNED MESSAGE-----',
          messageToSign(),
          '-----BEGIN SIGNATURE-----',
          _addressController.text,
          _signatureController.text,
          '-----END BITCOIN SIGNED MESSAGE-----',
        ].join("\n");
      });
    } else if (_selectedCurrency.contains('ETH')) {
      setState(() {
        _assetProofController.text = ['{', '  "address": "' + _addressController.text + '",', '  "msg": "${messageToSign().replaceAll('"', '\\"')}",', '  "sig": "' + _signatureController.text + '",', '  "version": "3",', '  "signer": "web3"', '}'].join("\n");
      });
    } else {
      throw ('Unknown currency: ' + _selectedCurrency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.title.copyWith(color: Colors.black45);
    String _hintAddress, _hintSignature;

    dbgPrint('selectedCurrency = ' + _selectedCurrency);

    if (_selectedCurrency.contains('BTC')) {
      _hintAddress = '1JpiTWauQdtysbynNp88dWeuyg2gBbK...';
      _hintSignature = 'H3fVd...KFM=';
    } else if (_selectedCurrency.contains('ETH')) {
      _hintAddress = '0xc02aaa39b223fe8d0a0e5c4f27ead...';
      _hintSignature = '0xfeb4...';
    } else {
      throw ('Unknown currency: ' + _selectedCurrency);
    }

    _updateProof();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("Add Proof of Wallet Ownership")),
        body: FlexibleScrollView.build(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("3. Paste Proof Parameters", style: title),
              SizedBox(height: 8),
              Text("Paste here your rich wallet address and the message signature.", style: TextStyle(fontSize: 15.0)),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Address', hintText: 'E.g. ' + _hintAddress),
                maxLines: 1,
                controller: _addressController,
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Signature', hintText: 'E.g. ' + _hintSignature),
                maxLines: 1,
                controller: _signatureController,
              ),
              SizedBox(height: 8),
              TextField(
                enabled: false,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Proof contents',
                ),
                maxLines: 10,
                controller: _assetProofController,
              ),
              SizedBox(height: 8),
              FlatButton(
                  child: Text('I need help'),
                  textColor: Colors.blue,
                  onPressed: () {
                    launchBrowser('https://github.com/whalechat');
                  }),
              AppButton.buildBig(context, "Add proof", onPressed: _sendAssetProof)
            ],
          ),
        ));
  }

  Future<void> _sendAssetProof() async {
    var assetProofData;

    try {
      assetProofData = await parseAssetProofSignature(_selectedCurrency, _assetProofController.text);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER, backgroundColor: Color(0xff444444), textColor: Colors.white);
      return;
    }

    final ok = await sendSignature(_selectedCurrency, assetProofData['address'], assetProofData['msg'], assetProofData['sig']);
    if (ok) {
      await AppState.instance.storage.saveAssetProof(_selectedCurrency, assetProofData['address'], assetProofData['sig']);
      await AppState.instance.storage.save();

      Fluttertoast.showToast(msg: "Account ownership verified!", gravity: ToastGravity.CENTER, backgroundColor: Color(0xff444444), textColor: Colors.white);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AddressProofListScreen()), (_) => false);
    } else {
      Fluttertoast.showToast(msg: "An error occurred while verifying signature", gravity: ToastGravity.TOP, backgroundColor: Color(0xff444444), textColor: Colors.white);
    }
  }
}

Future<String> _createAssetProofMessage(String address, String msg, String sig) async {
  return await signMessage(jsonEncode({
    "address": address,
    "msg": jsonDecode(msg),
    "sig": sig,
  }));
}

Future parseAssetProofSignature(currency, signatureContents) async {
  if (currency.contains('BTC') || currency.contains('ETH')) {
    String msg, address, sig;

    try {
      if (currency.contains('BTC')) {
        final lines = signatureContents.split('\n');
        if (lines[0] == "-----BEGIN BITCOIN SIGNED MESSAGE-----" && lines[lines.length - 4] == "-----BEGIN SIGNATURE-----" && lines[lines.length - 1] == "-----END BITCOIN SIGNED MESSAGE-----") {
          msg = lines.sublist(1, lines.length - 5 + 1).join("\n");
          address = lines[lines.length - 3];
          sig = lines[lines.length - 2];
          await AppState.instance.cryptoUtilsChannel.verifyBtc(sig, msg, address);
        } else
          throw ('Wrong signature format');
      } else if (currency.contains('ETH')) {
        try {
          signatureContents = signatureContents.replaceAll("\\", "");
          signatureContents = signatureContents.replaceAll("\"{", "{");
          signatureContents = signatureContents.replaceAll("}\"", "}");
          Map<String, dynamic> signatureJson = json.decode(signatureContents);

          address = signatureJson['address'];
          msg = jsonEncode(signatureJson['msg']);
          sig = signatureJson['sig'];
          sig = sig.replaceAll('0x', '');
        } catch (_) {
          throw ('Wrong signature format');
        }
        await AppState.instance.cryptoUtilsChannel.verifyEth(sig, msg, address);
      }

      if (AppState.instance.storage.cryptoAccounts.where((cryptoAccount) => cryptoAccount.address == address).isNotEmpty) {
        throw ('Proof for address $address was already entered');
      }
    } catch (e, s) {
      throw ('Could not verify the provided signed message');
    }

    return {"address": address, "msg": msg, "sig": sig};
  } else {
    throw ('Unknown currency: ' + currency);
  }
}

Future<bool> sendSignature(String currency, String address, String msg, String sig) async {
  await AppState.instance.apiService.registerAssetProof(currency, address, await _createAssetProofMessage(address, msg, sig));
  return true;
}
