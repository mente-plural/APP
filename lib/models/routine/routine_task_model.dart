import 'package:flutter/material.dart';

class RoutineTaskModel {
  final String id;
  final String title;
  final TimeOfDay time;
  final bool isCompleted;
  final String? icon;
  final String? color;
  final List<int> weekDays; // 1 = Monday, 7 = Sunday

  RoutineTaskModel({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
    this.icon,
    this.color,
    this.weekDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  factory RoutineTaskModel.fromMap(Map<String, dynamic> map) {
    final timeStr = map['time']?.toString() ?? '08:00';
    final parts = timeStr.split(':');
    
    return RoutineTaskModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      time: TimeOfDay(
        hour: parts.length > 0 ? int.tryParse(parts[0]) ?? 8 : 8,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
      isCompleted: map['isCompleted'] ?? false,
      icon: map['icon']?.toString(),
      color: map['color']?.toString(),
      weekDays: List<int>.from(map['weekDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'isCompleted': isCompleted,
      'icon': icon,
      'color': color,
      'weekDays': weekDays,
    };
  }

  RoutineTaskModel copyWith({
    String? title,
    TimeOfDay? time,
    bool? isCompleted,
    String? icon,
    String? color,
    List<int>? weekDays,
  }) {
    return RoutineTaskModel(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      weekDays: weekDays ?? this.weekDays,
    );
  }
}
