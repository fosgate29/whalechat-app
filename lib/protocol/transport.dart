import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/utils/utils.dart';

Future<String> signMessage(String payload) async {
  var payloadHex = hex.encode(utf8.encode(payload));
  List<dynamic> signature = await AppState.instance.cryptoUtilsChannel.sign(payloadHex, AppState.instance.secretKey);

  String j = jsonEncode({
    'signaturePubKey': AppState.instance.publicKey,
    'signature': signature[0].toString(),
    'payload': jsonDecode(payload)
  });
  return j;
}

Future<String> verifyMessage(String packetStr) async {
  var packet = json.decode(packetStr);
  var payload = json.encode(packet['payload']);
  var payloadHex = hex.encode(utf8.encode(payload));

  try {
    if (await AppState.instance.cryptoUtilsChannel.verify(packet['signature'], payloadHex, packet['signaturePubKey'])) {
      return payload;
    }
  } catch(e) {
    dbgPrint('verifyMessage error: ' + e.toString());
  }
  return null;
}

