import 'package:flutter/material.dart';
import 'package:whalechat_app/utils/app_state.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings > Notifications")),

      body: ListView(children: [
        SwitchListTile(
          title: Text("All notifications"),
          value: AppState.instance.allNotificationsEnabled,
          onChanged: (x) {
            setState(() {
              AppState.instance.allNotificationsEnabled = x;
              AppState.instance.chatroomMessagesNotificationsEnabled = x;
              AppState.instance.chatroomMentionsNotificationsEnabled = x;
              AppState.instance.privateMessagesNotificationsEnabled = x;
            });
          }
        ),

        SwitchListTile(
          title: Text("Chatroom messages"),
          value: AppState.instance.chatroomMessagesNotificationsEnabled,
          onChanged: (x) {
            setState(() => AppState.instance.chatroomMessagesNotificationsEnabled = x);

            (() async {
              final lobby = await AppState.instance.apiService.getLobby();
              final rooms = Map.fromIterables(
                lobby.rooms.map((r) => r.topic), lobby.rooms);

              AppState.instance.fcmDisableTopics(
                  (topic) => rooms[topic] == null ? true : !rooms[topic].isDirectMessage);
            })();
          }
        ),

//        SwitchListTile(
//          title: Text("Chatroom mentions"),
//          value: AppState.instance.chatroomMentionsNotificationsEnabled,
//          onChanged: (x) => setState(() {
//            AppState.instance.chatroomMentionsNotificationsEnabled = x;
//          }),
//        ),

        SwitchListTile(
          title: Text("Private messages"),
          value: AppState.instance.privateMessagesNotificationsEnabled,
          onChanged: (x) {
            setState(() => AppState.instance.privateMessagesNotificationsEnabled = x);

            (() async {
              final lobby = await AppState.instance.apiService.getLobby();
              final rooms = Map.fromIterables(
                lobby.rooms.map((r) => r.topic), lobby.rooms);

              AppState.instance.fcmDisableTopics(
                  (topic) => rooms[topic] == null ? true : rooms[topic].isDirectMessage);
            })();
          }
        ),
      ])
    );
  }
}
