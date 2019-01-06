import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whalechat_app/widgets/app_drawer.dart';
import 'package:whalechat_app/widgets/identicon.dart';
import 'package:whalechat_app/models/room.dart';
import 'package:whalechat_app/screens/chat_join_screen.dart';
import 'package:whalechat_app/screens/chat_screen.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/utils/utils.dart';

class ChatListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with TickerProviderStateMixin {
  var _tabs = <String>[];
  var _rooms = <Room>[];
  var _tabController = TabController(length: 0, vsync: null);

  @override
  void didUpdateWidget(ChatListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> refreshLobby() {
    return AppState.instance.apiService.getLobby().then((lobby) {
      if (!mounted) return;

      setState(() {
        _rooms = lobby.rooms;
        _tabs = lobby.rooms.map((r) => r.category).toSet().toList();

        if (!_tabs.contains("Direct Messages"))
          _tabs.add("Direct Messages");

        _tabs.sort((a, b) {
          if (a == 'Direct Messages') return 1;
          if (b == 'Direct Messages') return -1;
          return a.compareTo(b);
        });
        _tabController = TabController(length: _tabs.length, vsync: this);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    refreshLobby();

    checkUpdate(context);
    AppState.instance.configureFcm(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AppDrawer.build(context),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((x) => _buildTab(context, x)).toList()
      )
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Chat Rooms"),
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs.map((x) => Tab(text: x)).toList()
      )
    );
  }


  Container _buildTab(BuildContext context, String category) {
    final tabRooms = _rooms.where((x) => x.category == category).toList();

    return Container(
      padding: EdgeInsets.all(16.0),
      child: RefreshIndicator(
        child:  ListView(children: [
          Text("${tabRooms.length} rooms"),
          Divider()
        ] + tabRooms.map((x) => _buildRoomTile(context, x)).toList()),
        onRefresh: () => Future.delayed(Duration(seconds: 1), () => true)
      )
    );
  }

  ListTile _buildRoomTile(BuildContext context, Room room) {
    final title = room.isDirectMessage
      ? "Chat with ${room.directMessageOther.nickname}"
      : room.title;

    final avatar = room.isDirectMessage
      ? Identicon.of(room.directMessageOther)
      : CircleAvatar(
        child: Text(room.title[0]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      );

    return ListTile(
      leading: avatar,
      title: Text(title),
      subtitle: Text("${room.subtitle} | ${room.members.length} members"),
      onTap: () => _enterRoom(context, room)
    );
  }

  void _enterRoom(BuildContext context, Room room) {
    final imInTheRoom = room.members.any(
        (x) => x.publicKey == AppState.instance.publicKey);

    Navigator.push(context, MaterialPageRoute(builder: (_) =>
      imInTheRoom ? ChatScreen(room: room) : ChatJoinScreen(room: room))
    ).then((_) async {
      await refreshLobby();
      if (mounted) {
        setState(() {
          _tabController.index = _tabs.indexOf(room.category);
        });
      }
    });
  }
}
