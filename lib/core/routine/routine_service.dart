import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/routine_task_model.dart';
import 'routine_client.dart';

class RoutineService {
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;

  RoutineService._internal();

  final RoutineClient _routineClient = RoutineClient();

  final StreamController<List<RoutineTaskModel>> _tasksController = StreamController<List<RoutineTaskModel>>.broadcast();
  Stream<List<RoutineTaskModel>> get tasksStream => _tasksController.stream;

  List<RoutineTaskModel> _cachedTasks = [];
  List<RoutineTaskModel> get cachedTasks => _cachedTasks;

  Future<List<RoutineTaskModel>> loadTodayRoutines() async {
    try {
      final List<Map<String, dynamic>> rawTasks = await _routineClient.fetchRoutineTasks();
      _cachedTasks = rawTasks.map((json) => RoutineTaskModel.fromJson(json)).toList();
      _sortAndEmit();
      return _cachedTasks;
    } catch (e) {
      debugPrint("❌ [RoutineService] Erro ao carregar rotinas: $e");
      return [];
    }
  }

  Future<RoutineTaskModel?> createNewTask(RoutineTaskModel templateTask) async {
    try {
      final response = await _routineClient.createTask({
        'title': templateTask.title,
        'description': templateTask.description,
        'time': templateTask.time,
        'priority': templateTask.priority,
      });
      debugPrint(templateTask.time);
      final taskData = response['data'] ?? response;
      if (taskData != null && taskData is Map) {
        final createdTask = RoutineTaskModel.fromJson(taskData.cast<String, dynamic>());
        _cachedTasks.add(createdTask);
        _sortAndEmit();
        return createdTask;
      }
      return null;
    } catch (e) {
      debugPrint("❌ [RoutineService] Falha ao criar tarefa: $e");
      return null;
    }
  }

  /// Gerencia modificações completas ou parciais (incluindo status e edições textuais)
  Future<bool> editTask(String taskId, RoutineTaskModel updatedData) async {
    final index = _cachedTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final oldTask = _cachedTasks[index];

    // Atualização Otimista na interface
    _cachedTasks[index] = updatedData;
    _sortAndEmit();
    debugPrint(updatedData.time);

    try {
      final response = await _routineClient.updateTask(taskId, {
        'title': updatedData.title,
        'description': updatedData.description,
        'time': updatedData.time,
        'isCompleted': updatedData.isCompleted,
        'priority': updatedData.priority,
      });

      if (response.isEmpty) {
        _rollback(index, oldTask);
        return false;
      }
      return true;
    } catch (e) {
      _rollback(index, oldTask);
      return false;
    }
  }

  /// Atalho rápido para inverter apenas o status de conclusão
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final index = _cachedTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final updated = _cachedTasks[index].copyWith(isCompleted: isCompleted);
    return await editTask(taskId, updated);
  }

  Future<bool> removeTask(String taskId) async {
    try {
      await _routineClient.deleteTask(taskId);
      _cachedTasks.removeWhere((t) => t.id == taskId);
      _sortAndEmit(); // Notifica todos os ouvintes (Home, Routine Page, etc)
      return true;
    } catch (e) {
      debugPrint("❌ [RoutineService] Falha ao deletar tarefa: $e");
      return false;
    }
  }

  bool isAllTasksCompleted() {
    if (_cachedTasks.isEmpty) return false;
    return _cachedTasks.every((task) => task.isCompleted);
  }

  void _sortAndEmit() {
    _cachedTasks.sort((a, b) => a.time.compareTo(b.time));
    // Emitimos uma cópia da lista para garantir que o StreamBuilder detecte a mudança de estado
    _tasksController.add(List.from(_cachedTasks));
  }

  void _rollback(int index, RoutineTaskModel oldTask) {
    _cachedTasks[index] = oldTask;
    _sortAndEmit();
  }

  void dispose() {
    _tasksController.close();
  }
}