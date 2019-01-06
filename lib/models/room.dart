import 'package:json_annotation/json_annotation.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/models/identity.dart';

part 'room.g.dart';

@JsonSerializable(includeIfNull: false)
class Room {
  final String title;
  final String subtitle;
  final String category;
  final String topic;
  final String requiredCurrency;
  final num requiredAmount;
  final bool public;
  final Set<Identity> members;
  int myMessageCount = 0;

  Room({
    this.title, this.subtitle,
    this.category, this.topic,
    this.requiredCurrency,
    this.requiredAmount,
    this.public,
    this.members,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  String pullNonce() {
    if (myMessageCount == null)
      myMessageCount = 0;

    return (myMessageCount++).toString() +  ":" + this.topic;
  }

  bool get isDirectMessage => members.length == 2 && category == 'Direct Messages';
  Identity get directMessageOther => members.firstWhere((id) => id.publicKey != AppState.instance.publicKey);
}
