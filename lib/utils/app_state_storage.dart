import 'dart:async';
import 'dart:convert';

import 'package:whalechat_app/models/assetProof.dart';
import 'package:whalechat_app/models/cryptoAccount.dart';
import 'package:whalechat_app/models/identity.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';

class AppStateStorage {
  var prefs; // SharedPreferences.getInstance()

  // Identity
  String secretKeyEncrypted; // `secretKey` encrypted with the password's hash
  String passwordHashSaltHex; // the hash salt with which the password was hashed
  String chatKeyPairSeedEncryptedHex; // seed to empirically generate `chatKeyPair`
  String nonceHex; // the nonce with with the password hash is symmetrically encrypted
  String nickname;

  // Config
  bool telemetryEnabled;

  // Rooms & contacts
  Set<String> fcmSubscribedTopics = Set();

  Set<Identity> identityBook = new Set<Identity>(); // key is the identity's pubKey

  // Asset proofs / accounts
  List<CryptoAccount> cryptoAccounts = [];

  Future init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  bool get hasIdentity => passwordHashSaltHex != null && secretKeyEncrypted != null && nonceHex != null && nickname != null;

  Future save() async {
    await init();
    prefs.setString('secretKeyEncrypted', secretKeyEncrypted);
    prefs.setString('passwordHashSaltHex', passwordHashSaltHex);
    prefs.setString('chatKeyPairSeedEncryptedHex', chatKeyPairSeedEncryptedHex);
    prefs.setString('nonceHex', nonceHex);
    prefs.setString('nickname', nickname);
    prefs.setBool('telemetryEnabled', telemetryEnabled);
    prefs.setStringList('cryptoAccounts', cryptoAccounts.map((c) => json.encode(c.toJson())).toList());
    prefs.setStringList("fcmSubscribedTopics", fcmSubscribedTopics.toList());
  }

  Future<void> load() async {
    await init();
    passwordHashSaltHex = prefs.getString('passwordHashSaltHex');
    secretKeyEncrypted = prefs.getString('secretKeyEncrypted');
    nonceHex = prefs.getString('nonceHex');
    nickname = prefs.getString('nickname');
    telemetryEnabled = prefs.getBool('telemetryEnabled');
    chatKeyPairSeedEncryptedHex = prefs.getString('chatKeyPairSeedEncryptedHex');
    cryptoAccounts = (prefs.getStringList('cryptoAccounts') ?? []).map<CryptoAccount>((v) => CryptoAccount.fromJson(json.decode(v))).toList();
  }

  void clear() {
    passwordHashSaltHex = null;
    secretKeyEncrypted = null;
    nonceHex = null;
    nickname = null;
    telemetryEnabled = null;
    fcmSubscribedTopics = Set();
  }

  Future<void> saveAssetProof(currency, address, sig) async {
    CryptoAccount cryptoAccount = CryptoAccount(symbol: currency, address: address);
    await cryptoAccount.refreshBalance();
    cryptoAccount.assetProof = AssetProof(symbol: currency, address: address, signature: sig);
    AppState.instance.storage.cryptoAccounts.add(cryptoAccount);
  }

  Future<void> addBookIdentity(Identity identity) async {
    await updateBookIdentityAssetProof(identity);
    identityBook.add(identity);
  }

  Future<void> updateBookIdentityAssetProof(Identity identity) async {
    final List<AssetProof> assetProofs = await AppState.instance.apiService.requestAssetProofs(identity.publicKey);

    if (identity.accounts == null) {
      identity.accounts = new List<CryptoAccount>();
    }

    for (final AssetProof assetProof in assetProofs) {
      CryptoAccount account = identity.accounts.firstWhere((account) => account.address == assetProof.address, orElse: () => null);

      if (account == null) {
        account = new CryptoAccount(symbol: assetProof.symbol, address: assetProof.address);
        account.assetProof = assetProof;
        identity.accounts.add(account);
      }

      await account.refreshBalance();
    }

    AppState.instance.storage.identityBook.add(identity);
  }

  Decimal getBalance(String symbol) {
    Decimal balance = Decimal.parse('0');
    for (CryptoAccount account in cryptoAccounts) {
      if (account.symbol == symbol) {
        balance += Decimal.parse(account.balance);
      }
    }
    return balance;
  }
}
