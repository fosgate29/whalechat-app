import 'package:logging/logging.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/main.dart';

void main() async {
  Logger.root.level = Level.FINE;
  AppState.instance.env = AppEnvironment.development;

  mainImpl();
}

