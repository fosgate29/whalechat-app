import 'dart:async';
import 'dart:convert';

import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/models/assetProof.dart';
import 'package:whalechat_app/protocol/transport.dart';
import 'package:whalechat_app/utils/utils.dart';

Future validateAssetProof(AssetProof assetProof) async {
    final String packet = assetProof.toJson()['signature'];
    await verifyMessage(packet);
    final payload = jsonDecode(packet)['payload'];

    final payloadObj = payload;
    final sig = payloadObj['sig'];
    final msg = jsonEncode(payloadObj['msg']);
    final address = payloadObj['address'];

    final symbol = assetProof.toJson()['symbol'].toString().toLowerCase();

    if (symbol == 'eth') {
      await AppState.instance.cryptoUtilsChannel.verifyEth(sig, msg, address);
    } else {
      await AppState.instance.cryptoUtilsChannel.verifyBtc(sig, msg, address);
    }

    final signedMessageObj = jsonDecode(msg);

    {
      // asset proof verification
      if (signedMessageObj['application'] != 'wc') {
        throw ('Unsupported application in asset proof message');
      }

      if (signedMessageObj['version'] != '1') {
        throw ('Unsupported asset proof message version');
      }
      if (assetProof.address != address) {
        throw ('Found inconsistent address in asset proof');
      }

      if (assetProof.symbol.toLowerCase() != symbol.toLowerCase()) {
        throw ('Found inconsistent currency symbol in asset proof');
      }

      if (jsonDecode(packet)['signaturePubKey'] != signedMessageObj['pubKey']) {
        throw ('Found inconsistent pubKey in asset proof');
      }
    }

    dbgPrint('Asset proof verified: ${assetProof.symbol} address ${assetProof.address} is owned by pubKey ${signedMessageObj['pubKey']}');
}
