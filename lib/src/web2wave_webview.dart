import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web2wave/web2wave.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web2WaveWebScreen extends StatefulWidget {
  final String url;
  final bool allowBackNavigation;
  final Web2WaveWebListener? listener;
  final Color backgroundColor;

  const Web2WaveWebScreen({
    super.key,
    required this.url,
    required this.allowBackNavigation,
    this.listener,
    required this.backgroundColor,
  });

  @override
  State<Web2WaveWebScreen> createState() => _Web2WaveWebScreenState();
}

class _Web2WaveWebScreenState extends State<Web2WaveWebScreen> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoaded = true;
            });
          },
        ),
      )
      ..setBackgroundColor(widget.backgroundColor)
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
      widget.listener?.onQuizFinished(eventData);
    } else if (event == 'Close webview') {
      widget.listener?.onClose(eventData);
    } else {
      widget.listener?.onEvent(event: event, data: eventData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (b, r) async {
        if (widget.allowBackNavigation) {
          final canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            _controller.goBack();
          } else {
            widget.listener?.onClose({});
          }
        }
      },
      child: Stack(
        children: [
          if (Platform.isIOS && widget.allowBackNavigation)
            GestureDetector(
              onHorizontalDragUpdate: (details) async {
                if (details.globalPosition.dx < 150 && details.delta.dx > 0) {
                  final canGoBack = await _controller.canGoBack();
                  if (canGoBack) {
                    _controller.goBack();
                  } else {
                    widget.listener?.onClose({});
                  }
                }
              },
              child: WebViewWidget(controller: _controller),
            )
          else
            WebViewWidget(controller: _controller),
          if (!_isLoaded) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
