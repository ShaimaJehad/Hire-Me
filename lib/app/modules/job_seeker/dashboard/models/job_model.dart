import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String companyId;
  final String companyName;

  final String mainFieldId;
  final String mainFieldName;
  final String mainFieldIconUrl;

  final String subFieldId;
  final String subFieldName;
  final String subFieldIconUrl;

  final String title;
  final String description;
  final String requirements;
  final String jobType;
  final String workMode;
  final String status;
  final String location;
  final String salary;
  final String logoUrl;

  final num? minSalary;
  final num? maxSalary;

  final bool isActive;
  final bool isDeleted;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  JobModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.mainFieldId,
    required this.mainFieldName,
    this.mainFieldIconUrl = '',
    this.subFieldId = '',
    this.subFieldName = '',
    this.subFieldIconUrl = '',
    required this.title,
    required this.description,
    required this.requirements,
    required this.jobType,
    required this.workMode,
    required this.status,
    required this.location,
    required this.salary,
    required this.logoUrl,
    this.minSalary,
    this.maxSalary,
    this.isActive = true,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromMap(String id, Map<String, dynamic> data) {
    return JobModel(
      id: id,
      companyId: data['companyId']?.toString() ?? '',
      companyName: data['companyName']?.toString() ?? '',

      mainFieldId: data['mainFieldId']?.toString() ?? '',
      mainFieldName:
          data['mainFieldName']?.toString() ??
          data['category']?.toString() ??
          '',
      mainFieldIconUrl: data['mainFieldIconUrl']?.toString() ?? '',

      subFieldId: data['subFieldId']?.toString() ?? '',
      subFieldName:
          data['subFieldName']?.toString() ??
          data['specialization']?.toString() ??
          '',
      subFieldIconUrl: data['subFieldIconUrl']?.toString() ?? '',

      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      requirements: data['requirements']?.toString() ?? '',
      jobType: data['jobType']?.toString() ?? 'FullTime',
      workMode: data['workMode']?.toString() ?? 'Remote',
      status: data['status']?.toString() ?? 'Open',
      location: data['location']?.toString() ?? '',
      salary: data['salary']?.toString() ?? '',
      logoUrl:
          data['logoUrl']?.toString() ??
          data['companyLogoUrl']?.toString() ??
          '',

      minSalary: data['minSalary'] is num ? data['minSalary'] as num : null,
      maxSalary: data['maxSalary'] is num ? data['maxSalary'] as num : null,

      isActive: data['isActive'] as bool? ?? true,
      isDeleted: data['isDeleted'] as bool? ?? false,

      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,

      'mainFieldId': mainFieldId,
      'mainFieldName': mainFieldName,
      'mainFieldIconUrl': mainFieldIconUrl,
      'category': mainFieldName,

      'subFieldId': subFieldId,
      'subFieldName': subFieldName,
      'subFieldIconUrl': subFieldIconUrl,
      'specialization': subFieldName,

      'title': title,
      'description': description,
      'requirements': requirements,
      'jobType': jobType,
      'workMode': workMode,
      'status': status,
      'location': location,
      'salary': salary,
      'logoUrl': logoUrl,

      'minSalary': minSalary,
      'maxSalary': maxSalary,

      'isActive': isActive,
      'isDeleted': isDeleted,

      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isOpen => status.toLowerCase() == 'open';

  bool get isClosed => status.toLowerCase() == 'closed';

  bool get isDeletedJob => isDeleted || status.toLowerCase() == 'deleted';
}

class MainFieldModel {
  final String id;
  final String name;
  final String iconUrl;

  MainFieldModel({required this.id, required this.name, required this.iconUrl});

  factory MainFieldModel.fromMap(String id, Map<String, dynamic> data) {
    return MainFieldModel(
      id: id,
      name: data['name']?.toString() ?? '',
      iconUrl: data['iconUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconUrl': iconUrl};
  }
}

class SubFieldModel {
  final String id;
  final String name;
  final String iconUrl;

  SubFieldModel({required this.id, required this.name, required this.iconUrl});

  factory SubFieldModel.fromMap(String id, Map<String, dynamic> data) {
    return SubFieldModel(
      id: id,
      name: data['name']?.toString() ?? '',
      iconUrl: data['iconUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconUrl': iconUrl};
  }
}
