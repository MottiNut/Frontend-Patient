// lib/models/notification_model.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontendpatient/models/notification/notification_type.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;
  final String? planId;
  final String? patientId;
  final String? reason;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
    this.planId,
    this.patientId,
    this.reason,
  });

  // Constructor desde Firebase Message
  factory NotificationModel.fromFirebaseMessage(RemoteMessage message) {
    final notificationType = _parseNotificationType(message.data['type']);

    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notificación',
      body: message.notification?.body ?? '',
      type: notificationType,
      data: message.data,
      timestamp: DateTime.now(),
      planId: message.data['planId'],
      patientId: message.data['patientId'],
      reason: message.data['reason'],
    );
  }

  // Constructor desde JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: _parseNotificationType(json['type']),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      planId: json['planId'],
      patientId: json['patientId'],
      reason: json['reason'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'planId': planId,
      'patientId': patientId,
      'reason': reason,
    };
  }

  // Crear copia con cambios
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? planId,
    String? patientId,
    String? reason,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      planId: planId ?? this.planId,
      patientId: patientId ?? this.patientId,
      reason: reason ?? this.reason,
    );
  }

  // Métodos helper
  bool get isPlanApproved => type == NotificationType.planApproved;
  bool get isPlanRejected => type == NotificationType.planRejected;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (notificationDate == today) {
      return 'Hoy ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Ayer ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Función helper para parsear el tipo de notificación
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toUpperCase()) {
      case 'PLAN_APPROVED':
        return NotificationType.planApproved;
      case 'PLAN_REJECTED':
        return NotificationType.planRejected;
      default:
        return NotificationType.unknown;
    }
  }
}