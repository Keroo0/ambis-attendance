enum AppNotificationType { attendance, grade, leave, announcement, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.referenceId,
  });

  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? referenceId;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: _parseType(map['type'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      referenceId: map['reference_id'] as String?,
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        referenceId: referenceId,
      );

  static AppNotificationType _parseType(String raw) {
    switch (raw) {
      case 'attendance':
        return AppNotificationType.attendance;
      case 'grade':
        return AppNotificationType.grade;
      case 'leave':
        return AppNotificationType.leave;
      case 'announcement':
        return AppNotificationType.announcement;
      default:
        return AppNotificationType.system;
    }
  }
}
