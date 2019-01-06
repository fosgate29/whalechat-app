import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(includeIfNull: false)
class Message {
  final String sender;
  final String body;
  final DateTime sentAt;

  const Message({this.sender, this.body, this.sentAt});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
