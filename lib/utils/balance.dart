import 'dart:convert';

import 'package:whalechat_app/utils/app_state.dart';

Future<String> getBalance(ccy, address) async {
  if (['BTC', 'ETH'].contains(ccy.toUpperCase())) {
    final url = "https://api.blockcypher.com/v1/${ccy.toLowerCase()}/main/addrs/$address/balance";
    final httpClient = AppState.instance.httpClient;
    return (json.decode((await httpClient.get(url)).body)['balance']).toString();
  }
  throw ("Unsupported currency: $ccy");
}
