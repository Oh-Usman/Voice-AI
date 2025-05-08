import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime dateTime;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
  });

  String get formattedDate => DateFormat('MMM d, y').format(dateTime);
  String get formattedTime => DateFormat('h:mm a').format(dateTime);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}