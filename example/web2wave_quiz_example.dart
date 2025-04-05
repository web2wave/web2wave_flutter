import 'package:flutter/material.dart';
import 'package:web2wave/web2wave.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Web2Wave.shared.initialize(apiKey: 'your-api-key');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Title'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Web2Wave.shared.openWebPage(
            context: context,
            webPageURL: 'your-url',
            listener: EventListener()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EventListener extends Web2WaveWebListener {
  @override
  void onEvent({required String event, Map<String, dynamic>? data}) {
    print("\n $event - [$data] \n");
  }

  @override
  void onClose(Map<String, dynamic>? data) {
    print("\n onClose - [$data] \n");
    Web2Wave.shared.closeWebPage();
  }

  @override
  void onQuizFinished(Map<String, dynamic>? data) {
    print("\n onQuizFinished - [$data] \n");
    Web2Wave.shared.closeWebPage();
  }
}
