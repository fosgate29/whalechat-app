import 'package:flutter/services.dart';

class IdentityService {

  static const channelCryptoUtils = const MethodChannel('whalechat.club/cryptoUtils');

  generateNewIdentity() async {
    String privKeyHex = await channelCryptoUtils.invokeMethod('getNewPrivateKey');
    String publicKeyHex = await channelCryptoUtils.invokeMethod('getPublicKeyFromPrivateKey');

    return [privKeyHex, publicKeyHex];
  }
}
