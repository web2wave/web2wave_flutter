import 'package:flutter/material.dart';

import 'helpers.dart';
import 'web2wave_base.dart';
import 'web2wave_webview.dart';

abstract class Web2WaveWebListener {
  void onEvent({required String event, Map<String, dynamic>? data});
  void onClose(Map<String, dynamic>? data);
  void onQuizFinished(Map<String, dynamic>? data);
}

extension Web2WaveQuiz on Web2Wave {
  void openWebPage(
      {required BuildContext context,
      required String webPageURL,
      Web2WaveWebListener? listener}) {
    assert(apiKey != null, 'You must initialize apiKey before use');
    assert(isValidUrl(webPageURL), 'You must provide valid url');

    final mediaQuery = MediaQuery.of(context);
    final int safeTop = mediaQuery.padding.top.toInt();
    final int safeBottom = mediaQuery.padding.bottom.toInt();

    showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) {
          dialogContext = context;
          return Web2WaveWebScreen(
              url:
                  '$webPageURL?webview_flutter=1&top_padding=$safeTop&bottom_padding=$safeBottom',
              listener: listener);
        });
  }

  void closeWebPage() {
    if (dialogContext != null) {
      Navigator.pop(dialogContext!);
    }
  }
}
