import 'package:freezed_annotation/freezed_annotation.dart';

part 'example.model.freezed.dart';
part 'example.model.g.dart';

/// Task Model - Immutable model for task data
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Task;

  const Task._();

  // ✅ ALWAYS use code generation for fromJson
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  // ✅ ALWAYS provide toCreateJson (exclude id, timestamps, computed fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
    };
  }

  // ✅ ALWAYS provide toUpdateJson (same as toCreateJson in most cases)
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
    };
  }

  // 💡 Optional: Add computed methods for derived operations
  Task markCompleted() {
    return copyWith(isCompleted: true, completedAt: DateTime.now());
  }

  Task markUncompleted() {
    return copyWith(isCompleted: false, completedAt: null);
  }
}
