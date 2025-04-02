import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web2wave/web2wave.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web2WaveWebScreen extends StatefulWidget {
  final String url;
  final Web2WaveWebListener? listener;

  const Web2WaveWebScreen({super.key, required this.url, this.listener});

  @override
  State<Web2WaveWebScreen> createState() => _Web2WaveWebScreenState();
}

class _Web2WaveWebScreenState extends State<Web2WaveWebScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);
          _handleJsMessage(data);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleJsMessage(Map<String, dynamic> data) {
    final event = data['event'];
    final eventData = data['data'];

    if (event == 'Quiz finished') {
      Web2Wave.shared.closeWebPage();
      widget.listener?.onQuizFinished(eventData);
    } else if (event == 'Close webview') {
      Web2Wave.shared.closeWebPage();
      widget.listener?.onClose(eventData);
    } else {
      widget.listener?.onEvent(event: event, data: eventData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
