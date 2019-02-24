import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:whalechat_app/utils/app_state.dart';
import 'package:whalechat_app/widgets/yes_no_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

const GITHUB_LATEST_RELEASE_API_URL = 'https://api.github.com/repos/whalechat/whalechat-app/releases/latest';

Future<void> launchBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void dbgPrint(Object x) {
  if (AppState.instance.env == AppEnvironment.development)
    print(x);
}

Future<void> checkUpdate(BuildContext context) async {
  if (AppState.instance.triedCheckUpdate)
    return;

  final resp = await AppState.instance.httpClient.get(GITHUB_LATEST_RELEASE_API_URL);
  final j = json.decode(resp.body);

  final latestVersion = j['tag_name'].substring(1); // trim first character 'v' out
  final currentVersion = (await PackageInfo.fromPlatform()).version;

  AppState.instance.triedCheckUpdate = true;

  if (currentVersion != latestVersion) {
    final downloadUrl = j['assets'][0]['browser_download_url'];

    showDialog(context: context, builder: (_) => YesNoDialog.build(
      context: context,
      title: "New version available: $currentVersion -> $latestVersion",
      content: "Would you like to download the latest version now?",
      onYes: () {
        launchBrowser(downloadUrl);
        Navigator.of(context).pop();
      },
      onNo: () {}
    ));
  }
}
