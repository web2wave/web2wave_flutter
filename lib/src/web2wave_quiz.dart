import 'package:flutter/material.dart';

import 'helpers.dart';
import 'web2wave_base.dart';
import 'web2wave_webview.dart';

extension Web2WaveQuiz on Web2Wave {
  void openWebPage(
      {required BuildContext context,
      required String webPageURL,
      bool useSafeArea = false}) {
    assert(apiKey != null, 'You must initialize apiKey before use');
    assert(isValidUrl(webPageURL), 'You must provide valid url');

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: useSafeArea,
      builder: (context) =>
          Web2WaveWebScreen(url: '$webPageURL?webview=1&webview_flutter=1'),
    );
  }
}
