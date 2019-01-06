import 'package:flutter/material.dart';
import 'package:whalechat_app/models/assetProof.dart';

class AddressProofDetailScreen extends StatefulWidget {
  final AssetProof assetProof;

  AddressProofDetailScreen(this.assetProof);

  @override
  State<StatefulWidget> createState() => _AddressProofDetailScreenState(
    assetProof);
}

class _AddressProofDetailScreenState extends State<AddressProofDetailScreen> {
  final AssetProof _assetProof;

  _AddressProofDetailScreenState(this._assetProof);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Address Proof")),
      body: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(_assetProof.symbol, style: Theme.of(context).textTheme.headline)),
            ]),
            Text(_assetProof.address, style: Theme.of(context).textTheme.subhead),
            Divider(),
            Text(""),
            Form(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Proof signature"),
                Text(_assetProof.signature)
              ])
            )
          ],
        ),
      )
    );
  }
}
