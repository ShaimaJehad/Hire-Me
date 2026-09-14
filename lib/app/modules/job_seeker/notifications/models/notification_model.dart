import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String icon;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String applicationId;
  final String jobTitle;
  final String companyName;
  final String status;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.icon = 'notifications',
    required this.timestamp,
    this.isRead = false,
    this.type = '',
    this.applicationId = '',
    this.jobTitle = '',
    this.companyName = '',
    this.status = '',
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      icon: data['icon'] as String? ?? 'notifications',
      timestamp: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      type: data['type'] as String? ?? '',
      applicationId: data['applicationId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      companyName: data['companyName'] as String? ?? '',
      status: data['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'icon': icon,
      'createdAt': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'applicationId': applicationId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'status': status,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? icon,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? applicationId,
    String? jobTitle,
    String? companyName,
    String? status,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      icon: icon ?? this.icon,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      applicationId: applicationId ?? this.applicationId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
    );
  }
}
