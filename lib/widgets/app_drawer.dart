import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whalechat_app/screens/address_proof_list_screen.dart';
import 'package:whalechat_app/screens/referral_codes_screen.dart';
import 'package:whalechat_app/screens/chat_list_screen.dart';
import 'package:whalechat_app/screens/login_screen.dart';
import 'package:whalechat_app/screens/settings_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';

class AppDrawer {
  static Drawer build(BuildContext context) {
      final tiles = [
        ListTile(
          title: Text("Chats"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ChatListScreen()));
          }
        ),

        ListTile(
          title: Text("Asset Proofs"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AddressProofListScreen()));
          }
        ),

        ListTile(
          title: Text("Referral Program"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ReferralCodesScreen()));
          }
        ),

        ListTile(
          title: Text("Settings"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => SettingsScreen()));
          }
        ),
      ];

      if (AppState.instance.env == AppEnvironment.development) {
        tiles.add(ListTile(
          title: Text("Clear Profile", style: TextStyle(color: Colors.red)),
          onTap: () async {
            await (await SharedPreferences.getInstance()).clear();
            AppState.instance.clear();
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (_) => false
            );
          },
        ));
      }

      return Drawer(child: ListView(children: tiles));
  }
}
