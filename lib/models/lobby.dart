import 'package:json_annotation/json_annotation.dart';
import 'package:whalechat_app/models/room.dart';

part 'lobby.g.dart';

@JsonSerializable(includeIfNull: false)
class Lobby {
  final List<Room> rooms;

  const Lobby({this.rooms});

  factory Lobby.fromJson(Map<String, dynamic> json) => _$LobbyFromJson(json);
  Map<String, dynamic> toJson() => _$LobbyToJson(this);
}


