import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:whalechat_app/screens/advanced_settings_screen.dart';
import 'package:whalechat_app/screens/edit_profile_screen.dart';
import 'package:whalechat_app/screens/notifications_settings_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/identicon.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _currentVersion;

  Future _load() async {
    _currentVersion = (await PackageInfo.fromPlatform()).version;
  }

  @override
  void initState() {
    super.initState();

    this._load().then((_) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final identityPubKey = AppState.instance.publicKey.substring(0, 10) + '...';
    final chatPubKey = hex.encode(AppState.instance.chatKeyPair.publicKey).substring(0, 10) + '...';

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),

      body: Column(children: [
        Row(children: [
          Identicon.of(AppState.instance.identity),
          SizedBox(width: 12),
          Column(
            children: [
              SizedBox(height: 16),
              Text("Nickname"),
              SizedBox(height: 16),
              Text("Identity pubkey"),
              SizedBox(height: 16),
              Text("Chat pubkey")
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),

          SizedBox(width: 16),

          Column(
            children: [
              SizedBox(height: 16),
              Text("@" + AppState.instance.storage.nickname, textAlign: TextAlign.left),
              SizedBox(height: 16),
              Text("$identityPubKey"),
              SizedBox(height: 16),
              Text("$chatPubKey")
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          )
        ]),

        SizedBox(height: 16),

        Expanded(child: ListView(children: [
          _buildListTile(Icons.face, "Profile", onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
              EditProfileScreen()
            ))
          ),

          _buildListTile(Icons.notifications, "Notifications", onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
              NotificationsSettingsScreen()
            ))
          ),

          _buildListTile(Icons.settings, "Advanced", onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
              AdvancedSettingsScreen()
            ))
          ),

          Divider(),

          SwitchListTile(
            title: Text("Telemetry"),
            subtitle: Text("Send crash reports and anonymous statistics to developers."),
            value: AppState.instance.storage.telemetryEnabled ?? false,
            onChanged: (x) {
              setState(() {
                AppState.instance.storage.telemetryEnabled = x;
                AppState.instance.storage.save();
              });
            }
          ),

          SwitchListTile(
            title: Text("Sandbox environment"),
            subtitle: Text("Run the app in showcase mode."),
            value: AppState.instance.storage.sandboxEnvironmentEnabled ?? false,
            onChanged: (x) {
              setState(() {
                AppState.instance.storage.sandboxEnvironmentEnabled = x;
                AppState.instance.storage.save();
                showToastRestartApp();
              });
            }
          ),

          ListTile(
            title: Text("Version"),
            subtitle: Text(_currentVersion),
          ),
        ],))
      ],)
    );
  }

  void showToastRestartApp() {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
      msg: "You need to restart the app to reflect the changes"
    );
  }

  _buildListTile<T>(IconData icon, String title, { GestureTapCallback onTap }) =>
    ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap == null ? () => null : onTap
    );
}
