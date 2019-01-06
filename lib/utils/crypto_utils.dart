import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:quiver/iterables.dart';

const BIP39_ENGLISH_WORDLIST_URL = 'https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt';

const CRYPTO_UTILS_CHANNEL = MethodChannel('whalechat.club/cryptoUtils');

Uint8List generateKey({int length = 32}) {
  final r = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => r.nextInt(255)));
}

String generateKeyHex({int length = 32}) {
  return hex.encode(generateKey(length: length));
}

int _pack(String bitstring) {
  var rv = 0;
  for (var i = 0; i < bitstring.length; i++) {
    rv = rv << 1;
    if (bitstring[i] == '1')
      rv += 1;
  }
  return rv;
}

// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki#Generating_the_mnemonic
List<String> mnemonicFromPrivateKey(List<String> wordlist, String privateKey) {
  final ent = hex.decode(privateKey);
  assert(ent.length == 16 || ent.length == 32);

  final entBits = ent.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');

  final hash = sha256.convert(ent);
  final checksum = hash.bytes
    .map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('')
    .substring(0, entBits.length ~/ 32);

  return partition((entBits + checksum).split(''), 11)
    .map((bits) => wordlist[_pack(bits.join())]).toList();
}

String mnemonicToPrivateKey(List<String> wordlist, List<String> mnemonic) {
  assert(mnemonic.length == 12 || mnemonic.length == 24);
  final inputBits = mnemonic.map((m) => wordlist.indexOf(m).toRadixString(2).padLeft(11, '0')).join("");

  final checksumBitsLength = (mnemonic.length == 24 ? 8 : 4);
  final entBits = inputBits.substring(0, inputBits.length - checksumBitsLength);

  final checksumBits = inputBits.substring(inputBits.length - checksumBitsLength, inputBits.length);

  final entBytes = partition(entBits.split(""), 8).map((bits) => _pack(bits.join())).toList();


  final checksumByte = mnemonic.length == 24
    ? sha256.convert(entBytes).bytes.first
    : (sha256.convert(entBytes).bytes.first >> 4);

  if (checksumByte.toRadixString(2).padLeft(checksumBitsLength, '0') != checksumBits)
    throw("Invalid checksum");

  return "0x" + hex.encode(entBytes);
}

class Signature {
  final String signature;
  final String messageHash;

  const Signature(this.signature, this.messageHash);
}

Future<Signature> ecSign(String payloadHex, String privateKeyHex) async {
  List<dynamic> rv = await CRYPTO_UTILS_CHANNEL.invokeMethod('sign', [payloadHex, privateKeyHex]);
  return Signature(rv[0], rv[1]);
}


abstract class CryptoUtilsChannelAbstract {
  Future<String> getNewPrivateKey();
  Future<String> getPublicKeyFromPrivateKey(String secretKey);
  Future<String> getAddressFromPrivateKey(String secretKey, String symbol);
  Future<Object> sign(String msg, String privKeyHex);
  Future<bool> verify(String signature, String msg, String pubKeyHex);
  Future<bool> verifyBtc(String sig, String msg, String address);
  Future<bool> verifyEth(String sig, String msg, String address);
  Future<Signature> ecSign(String payloadHex, String privateKeyHex);
}

class CryptoUtilsChannel implements CryptoUtilsChannelAbstract {
  Future<String> getNewPrivateKey() async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('getNewPrivateKey');
  }

  Future<String> getPublicKeyFromPrivateKey(String secretKey) async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('getPublicKeyFromPrivateKey', [secretKey]);
  }

  Future<String> getAddressFromPrivateKey(String secretKey, String symbol) async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('getAddressFromPrivateKey', [secretKey, symbol]);
  }

  Future<Object> sign(String msg, String privKeyHex) async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('sign', [msg, privKeyHex]);
  }

  Future<bool> verify(String signature, String msg, String pubKeyHex) async {
    try {
      return await CRYPTO_UTILS_CHANNEL.invokeMethod('verify', [signature, msg, pubKeyHex]);
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyBtc(String sig, String msg, String address) async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('verifyBtc', [sig, msg, address]);
  }

  Future<bool> verifyEth(String sig, String msg, String address) async {
    return await CRYPTO_UTILS_CHANNEL.invokeMethod('verifyEth', [sig, msg, address]);
  }

  Future<Signature> ecSign(String payloadHex, String privateKeyHex) async {
    List<dynamic> rv = await CRYPTO_UTILS_CHANNEL.invokeMethod('sign', [payloadHex, privateKeyHex]);
    return Signature(rv[0], rv[1]);
  }
}



