import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_ai/widgets/voice_dialog.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../services/llm_services.dart';


class VoiceFAB extends StatefulWidget {
  const VoiceFAB({super.key});

  @override
  State<VoiceFAB> createState() => _VoiceFABState();
}

class _VoiceFABState extends State<VoiceFAB> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final TaskController _taskController = Get.find();
  final GeminiService _llmService = GeminiService(apiKey: 'AIzaSyCmGoK7iY9yuypP8mm8XsgBcAuefglm8ns');

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _lastWords = result.recognizedWords;
          }),
        );
      }
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);

      if (_lastWords.isNotEmpty) {
        _processVoiceCommand(_lastWords);
      }
    }
  }

  Future<void> _processVoiceCommand(String command) async {
    try {
      final result = await _llmService.parseCommand(command);

      final action = result['action'];
      final title = result['title'] ?? '';
      final description = result['description'] ?? '';
      final dateTimeStr = result['date_time'];

      if (action == 'delete') {
        _handleDeleteCommand(title);
      } else {
        DateTime? dateTime;
        if (dateTimeStr != null) {
          dateTime = DateTime.tryParse(dateTimeStr);
        }

        Get.dialog(
          VoiceDialog(
            initialTitle: title,
            initialDescription: description,
            initialDateTime: dateTime,
            onSave: (title, description, dateTime) {
              if (action == 'create') {
                _handleCreateCommand(title, description, dateTime);
              } else if (action == 'update') {
                _handleUpdateCommand(title, description, dateTime);
              }
            },
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process command: $e');
    }
  }

  void _handleCreateCommand(String title, String description, DateTime dateTime) {
    final task = Task(
      id: _taskController.generateId(),
      title: title,
      description: description,
      dateTime: dateTime,
    );
    _taskController.addTask(task);
  }

  void _handleUpdateCommand(String title, String description, DateTime dateTime) {
    final taskToUpdate = _taskController.tasks.firstWhere(
          (task) => task.title.toLowerCase() == title.toLowerCase(),
      orElse: () => Task(
        id: '',
        title: '',
        description: '',
        dateTime: DateTime.now(),
      ),
    );

    if (taskToUpdate.id.isNotEmpty) {
      final updatedTask = taskToUpdate.copyWith(
        title: title,
        description: description,
        dateTime: dateTime,
      );
      _taskController.updateTask(taskToUpdate.id, updatedTask);
    } else {
      Get.snackbar('Error', 'Task not found for update');
    }
  }

  void _handleDeleteCommand(String title) {
    final taskToDelete = _taskController.tasks.firstWhere(
          (task) => task.title.toLowerCase() == title.toLowerCase(),
      orElse: () => Task(
        id: '',
        title: '',
        description: '',
        dateTime: DateTime.now(),
      ),
    );

    if (taskToDelete.id.isNotEmpty) {
      _taskController.deleteTask(taskToDelete.id);
    } else {
      Get.snackbar('Error', 'Task not found for deletion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isListening ? _stopListening : _startListening,
      tooltip: 'Voice Command',
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }
}