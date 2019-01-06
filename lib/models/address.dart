import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable(includeIfNull: false)
class Address {
  final String ccy;
  final String address;
  final String signedTxid;

  const Address({this.ccy, this.address, this.signedTxid});

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
