import 'package:flutter/material.dart';

class VoiceControlScreen extends StatelessWidget {
  const VoiceControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Control')),
      body: Center(child: Text('Voice Control Screen')),
    );
  }
}
