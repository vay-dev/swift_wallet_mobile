class Promotion {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String actionType;
  final String actionLink;
  final bool isActive;
  final int displayOrder;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.actionType,
    required this.actionLink,
    required this.isActive,
    required this.displayOrder,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      actionType: json['action_type'] as String,
      actionLink: json['action_link'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'action_type': actionType,
      'action_link': actionLink,
      'is_active': isActive,
      'display_order': displayOrder,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String content;
  final bool read;
  final Promotion? promotion;
  final DateTime createdAt;
  final DateTime? readAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.read,
    this.promotion,
    required this.createdAt,
    this.readAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      read: json['read'] as bool? ?? false,
      promotion: json['promotion'] != null
          ? Promotion.fromJson(json['promotion'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      timeAgo: json['time_ago'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'read': read,
      'promotion': promotion?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'time_ago': timeAgo,
    };
  }

  // Helper to get icon based on notification type
  String getIconType() {
    switch (type) {
      case 'SUCCESS':
        return 'success';
      case 'FAILED':
        return 'failed';
      case 'INFO':
        return 'info';
      case 'PROMO':
        return 'promo';
      default:
        return 'info';
    }
  }
}
