import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/app_button.dart';
import 'package:whalechat_app/widgets/app_drawer.dart';
import 'package:share/share.dart';
import 'package:whalechat_app/utils/utils.dart';

class ReferralCodesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReferralCodesScreenState();
}

class _ReferralCodesScreenState extends State<ReferralCodesScreen> {
  final _referralCodeController = TextEditingController(text: "");
  List<String> _codes = [];
  int _codeIndex = 0;
  String _selfCode;

  @override
  void initState() {
    super.initState();

    AppState.instance.apiService.getReferralCodes().then((rv) {
      if (rv is String && rv.startsWith("error")) {
      } else {
        setState(() {
          _referralCodeController.text = rv["self"];
          _selfCode = rv["self"];
          _codes = rv["codes"].cast<String>();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.title.copyWith(color: Colors.black45);
    return Scaffold(
        appBar: AppBar(title: Text("Referral Program")),
        drawer: AppDrawer.build(context),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("How does it work?", style: title),
                Divider(),
                Text("\nRefer whales to WhaleChat. If they submit verified asset proofs, you will be rewarded with WHALE tokens by the end of the referral program."),
                FlatButton(
                    child: Text('See details'),
                    textColor: Colors.blue,
                    onPressed: () {
                      launch('https://whalechat.club');
                    }),
                Text(""),
                Text("\nWho referred you?", style: title),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                    enabled: _selfCode == null ? true : false,
                    controller: _referralCodeController,
                    decoration: InputDecoration(hintText: "Referral Code"),
                  )),
                  AppButton.build(context, "Join", onPressed: _selfCode == null ? _associateReferralCode : null)
                ]),
                Divider(),
                Text("\nRefer more people", style: title),
                Divider(),
                Text(""),
                Text("Give these referral codes to people. If they refer whales, you will get some WHALE tokens too!"),
                Divider(),
                _codeBox(context),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )));
  }

  Container _codeBox(BuildContext context) {
    if (_codes.length > 0) {
      dbgPrint("_codes = " + _codes.toString());

      return Container(
          height: 80.0,
          child: Column(children: [
            Expanded(child: Text(_codes.elementAt(_codeIndex))),
            Row(children: [
              Spacer(),
              AppButton.build(context, "New", onPressed: () {
                setState(() {
                  _codeIndex++;
                });
              }),
              Spacer(),
              AppButton.build(context, "Share", icon: Icons.share, onPressed: () {
                Share.share(_codes.elementAt(_codeIndex));
              }),
              Spacer()
            ])
          ]));
    } else {
      return Container(child: Text('No codes available yet. You need to join first.'));
    }
  }

  Future<void> _associateReferralCode() async {
    await AppState.instance.apiService.associateReferralCode(_referralCodeController.text);
    await AppState.instance.apiService.createReferralCodes();
    Map<String, dynamic> rv = await AppState.instance.apiService.getReferralCodes();
    setState(() {
      _referralCodeController.text = rv["self"];
      _selfCode = rv["self"];
      _codes = rv["codes"].cast<String>();
    });
  }
}
