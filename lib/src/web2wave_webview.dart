import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web2WaveWebScreen extends StatefulWidget {
  final String url;

  const Web2WaveWebScreen({super.key, required this.url});

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
    debugPrint("Message from JS: $data");

    if (data['action'] == 'showAlert') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? '')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
