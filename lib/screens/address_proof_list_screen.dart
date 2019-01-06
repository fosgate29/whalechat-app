import 'package:flutter/material.dart';
import 'package:whalechat_app/screens/address_proof_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:whalechat_app/screens/new_address_proof_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/app_drawer.dart';

class AddressProofListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Address Proofs")),
      drawer: AppDrawer.build(context),
      body: _addressProofList(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
          NewAddressProofScreen()
        ))
      ),
    );
  }

  ListView _addressProofList(BuildContext context) {
    if (AppState.instance.storage.cryptoAccounts.length > 0) {
      final format = DateFormat("yMd");
      return ListView(children: AppState.instance.storage.cryptoAccounts.map((cryptoAccount) => ListTile(
        title: Text(cryptoAccount.address),
        subtitle: Text("Verified on ${format.format(
          DateTime.fromMillisecondsSinceEpoch(cryptoAccount.balanceTimestamp))}"),
        trailing: Text(cryptoAccount.displayBalance),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
            AddressProofDetailScreen(cryptoAccount.assetProof)
          ));
        },
      )
      ).toList());
    } else {
      return ListView(children: [
        ListTile(title: Text('You have not entered any asset proof yet.', style: TextStyle(color: Colors.grey)))
      ]);
    }
  }

}

