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
            useSafeArea: true), //use safe area is false by default
        child: const Icon(Icons.add),
      ),
    );
  }
}
