class ApplicationReviewModel {
  final String id;
  final String jobSeekerId;
  final String name;
  final String jobTitle;
  final String location;
  final String email;
  final String skills;
  final String experience;
  final String education;
  final String cvUrl;
  final String avatarUrl;
  final String status;
  final String appliedAt;
  final String updatedAt;
  final String applicantFcmToken;
  final String jobId;

  ApplicationReviewModel({
    required this.id,
    required this.jobSeekerId,
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.email,
    required this.skills,
    required this.experience,
    required this.education,
    required this.cvUrl,
    this.avatarUrl = '',
    this.status = 'Pending',
    required this.appliedAt,
    this.updatedAt = '',
    this.applicantFcmToken = '',
    this.jobId = '',
  });
}
