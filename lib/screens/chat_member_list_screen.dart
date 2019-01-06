import 'package:flutter/material.dart';
import 'package:whalechat_app/models/identity.dart';
import 'package:whalechat_app/models/room.dart';
import 'package:whalechat_app/screens/identity_detail_screen.dart';
import 'package:whalechat_app/widgets/identicon.dart';
import 'package:whalechat_app/utils/app_state.dart';

class ChatMemberListScreen extends StatefulWidget {
  final Room room;

  ChatMemberListScreen({Key key, @required this.room}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatMemberListScreenState();
}

class _ChatMemberListScreenState extends State<ChatMemberListScreen> {
  @override
  void initState() {
    super.initState();

    for (final identity in widget.room.members) {
      AppState.instance.storage.updateBookIdentityAssetProof(identity).then((_) =>
        setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.room.members.toList();

    return Scaffold(
      appBar: AppBar(title: Text("${members.length} members")),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (_, idx) => _buildTile(context, members[idx])
      ));
  }

}

ListTile _buildTile(BuildContext context, Identity identity) {
  return ListTile(
    leading: Identicon.of(identity),
    title: Text(identity.nickname),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => IdentityDetailScreen(identity: identity)));
    },
  );
}
