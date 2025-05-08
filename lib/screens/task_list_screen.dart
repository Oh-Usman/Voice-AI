import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/voice_fab.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: taskController.sortTasks,
          ),
        ],
      ),
      body: Obx(() {
        final tasks = taskController.tasks..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return tasks.isEmpty
            ? const Center(child: Text('No tasks yet. Add one with voice!'))
            : ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onDelete: () => taskController.deleteTask(task.id),
              onEdit: (updatedTask) =>
                  taskController.updateTask(task.id, updatedTask),
            );
          },
        );
      }),
      floatingActionButton: const VoiceFAB(),
    );
  }
}