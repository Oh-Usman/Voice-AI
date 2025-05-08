import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  late Box<Task> taskBox;
  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>('tasks');
  }

  List<Task> get tasks => taskBox.values.toList();

  void addTask(Task task) {
    try {
      taskBox.add(task);
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save task: $e');
    }
  }

  void updateTask(String id, Task updatedTask) {
    try {
      final task = taskBox.values.firstWhere((t) => t.id == id);
      final index = task.key as int;
      taskBox.putAt(index, updatedTask);
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: $e');
    }
  }

  void deleteTask(String id) {
    try {
      final task = taskBox.values.firstWhere((t) => t.id == id);
      task.delete();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task: $e');
    }
  }

  void sortTasks() {
    update(); // Just trigger a refresh
  }

  String generateId() => _uuid.v4();
}