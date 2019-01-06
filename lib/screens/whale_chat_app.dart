import 'package:flutter/material.dart';
import 'package:whalechat_app/screens/chat_list_screen.dart';
import 'package:whalechat_app/screens/login_screen.dart';
import 'package:whalechat_app/screens/pin_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';

class WhaleChatApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhaleChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppState.instance.hasIdentity ? PinScreen(ChatListScreen()) : LoginScreen()
    );
  }
}
