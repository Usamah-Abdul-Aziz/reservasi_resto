import 'package:uuid/uuid.dart';

enum NotificationType {
  newReservation,
  statusChange,
  reminder,
  cancellation,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? reservationId;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    this.reservationId,
    DateTime? createdAt,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'reservationId': reservationId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: NotificationType.values[map['type'] as int? ?? 0],
      reservationId: map['reservationId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? reservationId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      reservationId: reservationId ?? this.reservationId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get icon {
    switch (this) {
      case NotificationType.newReservation:
        return '🔔';
      case NotificationType.statusChange:
        return '📋';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.cancellation:
        return '❌';
    }
  }
}
