import 'application_review_model.dart';

class JobWithApplicants {
  final String jobId;
  final String jobTitle;
  final List<ApplicationReviewModel> applicants;

  JobWithApplicants({
    required this.jobId,
    required this.jobTitle,
    required this.applicants,
  });
}
