import 'package:hourz/shared/index.dart';
import '../models/example.model.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  // ============================================================================
  // Basic CRUD Operations
  // ============================================================================

  /// GET list - Fetch all items
  Future<List<Task>> getTasks() async {
    return await _apiService.getList(ApiEndpoints.tasks, Task.fromJson);
  }

  /// GET by ID - Fetch single item
  Future<Task> getTaskById(String id) async {
    return await _apiService.getById(ApiEndpoints.tasks, id, Task.fromJson);
  }

  /// POST - Create new item
  Future<Task> createTask(Task task) async {
    return await _apiService.create(
      ApiEndpoints.tasks,
      task.toCreateJson(), // ✅ Use toCreateJson (excludes id, timestamps)
      Task.fromJson,
    );
  }

  /// PUT - Update existing item
  Future<Task> updateTask(Task task) async {
    return await _apiService.update(
      ApiEndpoints.tasks,
      task.id,
      task.toUpdateJson(), // ✅ Use toUpdateJson
      Task.fromJson,
    );
  }

  /// DELETE - Remove item
  Future<void> deleteTask(String id) async {
    await _apiService.delete(ApiEndpoints.tasks, id);
  }

  // ============================================================================
  // Advanced Operations (Optional)
  // ============================================================================

  /// PATCH - Toggle task completion (custom endpoint)
  Future<Task> toggleTaskCompletion(String id) async {
    final response = await _apiService.update(
      '${ApiEndpoints.tasks}/$id/toggle',
      id,
      {}, // Empty body for toggle action
      Task.fromJson,
    );
    return response;
  }

  /// GET with query parameters - Filtering
  Future<List<Task>> getCompletedTasks() async {
    return await _apiService.getList(
      '${ApiEndpoints.tasks}?completed=true',
      Task.fromJson,
    );
  }

  /// GET with query parameters - Filtering
  Future<List<Task>> getPendingTasks() async {
    return await _apiService.getList(
      '${ApiEndpoints.tasks}?completed=false',
      Task.fromJson,
    );
  }
}
