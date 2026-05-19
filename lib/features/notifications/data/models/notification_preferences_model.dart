class NotificationPreferences {
  const NotificationPreferences({
    required this.userId,
    this.attendance = true,
    this.grade = true,
    this.leave = true,
    this.announcement = true,
    this.system = true,
  });

  final String userId;
  final bool attendance;
  final bool grade;
  final bool leave;
  final bool announcement;
  final bool system;

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) =>
      NotificationPreferences(
        userId: map['user_id'] as String,
        attendance: map['attendance'] as bool? ?? true,
        grade: map['grade'] as bool? ?? true,
        leave: map['leave'] as bool? ?? true,
        announcement: map['announcement'] as bool? ?? true,
        system: map['system'] as bool? ?? true,
      );

  NotificationPreferences copyWith({
    bool? attendance,
    bool? grade,
    bool? leave,
    bool? announcement,
    bool? system,
  }) =>
      NotificationPreferences(
        userId: userId,
        attendance: attendance ?? this.attendance,
        grade: grade ?? this.grade,
        leave: leave ?? this.leave,
        announcement: announcement ?? this.announcement,
        system: system ?? this.system,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'attendance': attendance,
        'grade': grade,
        'leave': leave,
        'announcement': announcement,
        'system': system,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
}
