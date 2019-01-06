import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:whalechat_app/models/identity.dart';
import 'package:whalechat_app/models/room.dart';
import 'package:whalechat_app/utils/app_state.dart';

String createSharePublicKey() {
  return jsonEncode({
    'messageType': 'sharePublicKey',
    'pubKey': AppState.instance.publicKey, // secp256k1 public key
    'chatPubKey': hex.encode(AppState.instance.chatKeyPair.publicKey), // default's NaCl public key
    'nickname': AppState.instance.storage.nickname
  });
}

Future<String> createPrivateMessage(
    String msg, String publicKeyTo, String nonce) async {
  var symKey = await SecretBox.generateKey();
  var symNonce = await SecretBox.generateNonce();
  var symKeyNonce = jsonEncode([hex.encode(symNonce), hex.encode(symKey)]);
  var messageEncryptedWithSymKey =
      hex.encode(await SecretBox.encrypt(msg, symNonce, symKey));

  var asymNonce = await CryptoBox.generateNonce();
  var symKeyEncryptedWithPubKeyUser = [
    hex.encode(asymNonce),
    hex.encode(await CryptoBox.encrypt(symKeyNonce, asymNonce,
        hex.decode(publicKeyTo), AppState.instance.chatKeyPair.secretKey))
  ];

  return jsonEncode({
    'messageType': 'privateMessage',
    'message': messageEncryptedWithSymKey,
    'pubKey': hex.encode(AppState.instance.chatKeyPair.publicKey),
    'symKey': symKeyEncryptedWithPubKeyUser
  });
}

Future<String> decodePrivateMessage(
    String payloadStr, String myPublicKey, String myPrivateKey) async {
  var payload = jsonDecode(payloadStr);

  assert(payload['messageType'] == 'privateMessage');

  var messageEncryptedWithSymKey = hex.decode(payload['message']);
  var hisPublicKey = hex.decode(payload['pubKey']);

  var asymNonce = hex.decode(payload['symKey'][0]);
  var symKeyEncryptedWithPubKeyUser = hex.decode(payload['symKey'][1]);

  var symKeyNonce = jsonDecode(await CryptoBox.decrypt(
      symKeyEncryptedWithPubKeyUser,
      asymNonce,
      hisPublicKey,
      hex.decode(myPrivateKey)));

  var symNonce = hex.decode(symKeyNonce[0]);
  var symKey = hex.decode(symKeyNonce[1]);
  var msg =
      await SecretBox.decrypt(messageEncryptedWithSymKey, symNonce, symKey);

  return msg;
}

Future<String> createMessageToRoom(
    String msg, Room room, List<String> roomPublicKeys, String nonce) async {
  var symKey = await SecretBox.generateKey();
  var symNonce = await SecretBox.generateNonce();

  var symMessage = jsonEncode([hex.encode(symNonce), hex.encode(symKey)]);
  var messageEncryptedWithSymKey =
      hex.encode(await SecretBox.encrypt(msg, symNonce, symKey));

  var symKeyEncryptedWithPubKeyUsers = {};
  for (int i = 0; i < roomPublicKeys.length; i++) {
    var myNonce = await CryptoBox.generateNonce();
    var symKeyEncryptedWithPubKeyUser = await CryptoBox.encrypt(
        symMessage,
        myNonce,
        hex.decode(roomPublicKeys[i]),
        AppState.instance.chatKeyPair.secretKey);

    var dictKey = roomPublicKeys[i];
    symKeyEncryptedWithPubKeyUsers[dictKey] = [
      hex.encode(myNonce),
      hex.encode(symKeyEncryptedWithPubKeyUser)
    ];
  }

  return jsonEncode({
    'messageType': 'messageToRoom',
    'room': room.title,
    'message': messageEncryptedWithSymKey,
    'pubKey': hex.encode(AppState.instance.chatKeyPair.publicKey),
    'symKeys': symKeyEncryptedWithPubKeyUsers
  });
}

Future<Object> decodeMessage(String payloadStr) async {
  if (payloadStr == null)
    return null;

  var payload = json.decode(payloadStr);
  var messageType = payload['messageType'];

  if (messageType == 'sharePublicKey') {
    return decodeSharePublic(payloadStr);
  } else if (messageType == 'privateMessage') {
    String message = await decodePrivateMessage(
        payloadStr,
        hex.encode(AppState.instance.chatKeyPair.publicKey),
        hex.encode(AppState.instance.chatKeyPair.secretKey));
    return message;
  } else if (messageType == 'messageToRoom') {
    return await decodeMessageToRoom(
        payloadStr,
        hex.encode(AppState.instance.chatKeyPair.publicKey),
        hex.encode(AppState.instance.chatKeyPair.secretKey));
  } else {
    throw ('Uknown messageType: ' + messageType);
  }
}

Identity decodeSharePublic(String payloadStr) {
  var json = jsonDecode(payloadStr);
  var i = new Identity(
      publicKey: json['pubKey'] as String,
      nickname: json['nickname'] as String,
      chatPublicKey: json['chatPubKey'] as String);
  return i;
}

Future<String> decodeMessageToRoom(
    String payloadStr, String myPublicKey, String myPrivateKey) async {
  var payload = jsonDecode(payloadStr);

  var messageEncryptedWithSymKey = hex.decode(payload['message']);
  var hisPublicKey = hex.decode(payload['pubKey']);

  if (!payload['symKeys'].containsKey(myPublicKey))
    return null;

  var myNonce = hex.decode(payload['symKeys'][myPublicKey][0]);
  var symKeyEncryptedWithPubKeyUser =
      hex.decode(payload['symKeys'][myPublicKey][1]);

  var symMessage2 = jsonDecode(await CryptoBox.decrypt(
      symKeyEncryptedWithPubKeyUser,
      myNonce,
      hisPublicKey,
      hex.decode(myPrivateKey)));

  var symNonce2 = hex.decode(symMessage2[0]);
  var symKey2 = hex.decode(symMessage2[1]);
  var msg2 =
      await SecretBox.decrypt(messageEncryptedWithSymKey, symNonce2, symKey2);

  return msg2;
}
