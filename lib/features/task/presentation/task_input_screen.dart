import 'package:flutter/material.dart';
import '../../voice_control/domain/voice_input_service.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});

  @override
  TaskInputScreenState createState() => TaskInputScreenState();
}

class TaskInputScreenState extends State<TaskInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final VoiceInputService _voiceInput = VoiceInputService();

  @override
  void initState() {
    super.initState();
    _voiceInput.initSpeech();
  }

  void _onMicPressed() async {
    if (_voiceInput.isListening) {
      _voiceInput.stopListening();
    } else {
      await _voiceInput.startListening((text) {
        setState(() {
          _controller.text = text;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Task Description',
                suffixIcon: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _onMicPressed,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save task logic
              },
              child: Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}
