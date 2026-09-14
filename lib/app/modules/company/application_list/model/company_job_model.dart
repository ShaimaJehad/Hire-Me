class CompanyJobModel {
  final String id;
  final String title;
  final String location;
  final String salary;
  final String jobType;
  final String workMode;
  final String status;
  final DateTime? createdAt;
  final String mainFieldId;
  final String mainFieldName;
  final int applicantCount;
  final num? minSalary;
  final num? maxSalary;
  final String description;
  final String requirements;
  final bool isDeleted;

  final String logoUrl;
  final String mainFieldIconUrl;
  final String subFieldIconUrl;

  CompanyJobModel({
    required this.id,
    required this.title,
    required this.location,
    this.salary = '',
    this.jobType = '',
    this.workMode = '',
    this.status = 'Open',
    this.createdAt,
    this.mainFieldId = '',
    this.mainFieldName = '',
    this.applicantCount = 0,
    this.minSalary,
    this.maxSalary,
    this.description = '',
    this.requirements = '',
    this.isDeleted = false,
    this.logoUrl = '',
    this.mainFieldIconUrl = '',
    this.subFieldIconUrl = '',
  });

  factory CompanyJobModel.fromMap(String id, Map<String, dynamic> map) {
    final minSalary = map['minSalary'] is num ? map['minSalary'] as num : null;
    final maxSalary = map['maxSalary'] is num ? map['maxSalary'] as num : null;

    String salaryText = map['salary']?.toString() ?? '';

    if (salaryText.isEmpty && minSalary != null && maxSalary != null) {
      salaryText = '\$${minSalary.toString()}-${maxSalary.toString()}';
    }

    DateTime? createdAtDate;
    final createdAtValue = map['createdAt'];

    try {
      if (createdAtValue != null) {
        createdAtDate = createdAtValue.toDate();
      }
    } catch (_) {
      createdAtDate = null;
    }

    return CompanyJobModel(
      id: id,
      title: map['title']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      salary: salaryText,
      jobType: map['jobType']?.toString() ?? '',
      workMode: map['workMode']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Open',
      mainFieldId: map['mainFieldId']?.toString() ?? '',
      mainFieldName:
          map['mainFieldName']?.toString() ?? map['category']?.toString() ?? '',
      createdAt: createdAtDate,
      minSalary: minSalary,
      maxSalary: maxSalary,
      description: map['description']?.toString() ?? '',
      requirements: map['requirements']?.toString() ?? '',
      isDeleted: map['isDeleted'] == true,

      logoUrl: map['logoUrl']?.toString() ?? '',
      mainFieldIconUrl: map['mainFieldIconUrl']?.toString() ?? '',
      subFieldIconUrl:
          map['subFieldIconUrl']?.toString() ??
          map['jobImageUrl']?.toString() ??
          map['imageUrl']?.toString() ??
          '',
    );
  }

  String get displayImageUrl {
    if (subFieldIconUrl.trim().isNotEmpty) return subFieldIconUrl.trim();
    if (mainFieldIconUrl.trim().isNotEmpty) return mainFieldIconUrl.trim();
    if (logoUrl.trim().isNotEmpty) return logoUrl.trim();
    return '';
  }

  String get datePosted {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  String get jobTypeLabel {
    switch (jobType) {
      case 'FullTime':
        return 'Full Time';
      case 'PartTime':
        return 'Part Time';
      default:
        return jobType;
    }
  }
}
// class CompanyJobModel {
//   final String id;
//   final String title;
//   final String location;
//   final String salary;
//   final String jobType;
//   final String workMode;
//   final String status;
//   final DateTime? createdAt;
//   final String mainFieldId;
//   final String mainFieldName;
//   final int applicantCount;
//   final num? minSalary;
//   final num? maxSalary;
//   final String description;
//   final String requirements;
//   final bool isDeleted;

//   CompanyJobModel({
//     required this.id,
//     required this.title,
//     required this.location,
//     this.salary = '',
//     this.jobType = '',
//     this.workMode = '',
//     this.status = 'Open',
//     this.createdAt,
//     this.mainFieldId = '',
//     this.mainFieldName = '',
//     this.applicantCount = 0,
//     this.minSalary,
//     this.maxSalary,
//     this.description = '',
//     this.requirements = '',
//     this.isDeleted = false,
//   });

//   factory CompanyJobModel.fromMap(String id, Map<String, dynamic> map) {
//     final minSalary = map['minSalary'] is num ? map['minSalary'] as num : null;
//     final maxSalary = map['maxSalary'] is num ? map['maxSalary'] as num : null;

//     String salaryText =
//         map['salary']?.toString() ?? map['salary']?.toString() ?? '';

//     if (salaryText.isEmpty && minSalary != null && maxSalary != null) {
//       salaryText = '\$${minSalary.toString()}-${maxSalary.toString()}';
//     }

//     DateTime? createdAtDate;
//     final createdAtValue = map['createdAt'];

//     try {
//       if (createdAtValue != null) {
//         createdAtDate = createdAtValue.toDate();
//       }
//     } catch (_) {
//       createdAtDate = null;
//     }

//     return CompanyJobModel(
//       id: id,
//       title: map['title']?.toString() ?? '',
//       location: map['location']?.toString() ?? '',
//       salary: salaryText,
//       jobType: map['jobType']?.toString() ?? '',
//       workMode: map['workMode']?.toString() ?? '',
//       status: map['status']?.toString() ?? 'Open',
//       mainFieldId: map['mainFieldId']?.toString() ?? '',
//       mainFieldName:
//           map['mainFieldName']?.toString() ?? map['category']?.toString() ?? '',
//       createdAt: createdAtDate,
//       minSalary: minSalary,
//       maxSalary: maxSalary,
//       description: map['description']?.toString() ?? '',
//       requirements: map['requirements']?.toString() ?? '',
//       isDeleted: map['isDeleted'] == true,
//     );
//   }

//   String get datePosted {
//     if (createdAt == null) return '';

//     final now = DateTime.now();
//     final diff = now.difference(createdAt!);

//     if (diff.inDays == 0) return 'Today';
//     if (diff.inDays == 1) return 'Yesterday';
//     if (diff.inDays < 7) return '${diff.inDays} days ago';

//     return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
//   }

//   String get jobTypeLabel {
//     switch (jobType) {
//       case 'FullTime':
//         return 'Full Time';
//       case 'PartTime':
//         return 'Part Time';
//       default:
//         return jobType;
//     }
//   }
// }
