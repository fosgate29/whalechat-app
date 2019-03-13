import 'dart:convert';

import 'package:whalechat_app/utils/app_state.dart';

Future<String> getBalance(ccy, address) async {
  if (['BTC', 'ETH'].contains(ccy.toUpperCase())) {
    if (AppState.instance.storage.sandboxEnvironmentEnabled == true) {
      if (ccy.toUpperCase() == 'BTC') {
        return "1000" + "00000000";
      }
      if (ccy.toUpperCase() == 'ETH') {
        return "200000" + "000000000000000000";
      }
    } else {
      final url = "https://api.blockcypher.com/v1/${ccy.toLowerCase()}/main/addrs/$address/balance";
      final httpClient = AppState.instance.httpClient;
      return (json.decode((await httpClient.get(url)).body)['balance']).toString();
    }
  }
  throw ("Unsupported currency: $ccy");
}
