class RoutineTaskModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final int priority;

  const RoutineTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    this.priority = 1,
  });

  RoutineTaskModel copyWith({
    String? title,
    String? description,
    String? time,
    bool? isCompleted,
    int? priority,
  }) =>
      RoutineTaskModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        time: time ?? this.time,
        isCompleted: isCompleted ?? this.isCompleted,
        priority: priority ?? this.priority,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time': time,
        'isCompleted': isCompleted,
        'priority': priority,
      };

  factory RoutineTaskModel.fromJson(Map<String, dynamic> json) =>
      RoutineTaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        time: json['time'],
        isCompleted: json['isCompleted'],
        priority: json['priority'] ?? 1,
      );
}
