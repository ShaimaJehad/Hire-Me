part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const splash = _Paths.splash;
  static const onboarding = _Paths.onboarding;
  static const authSelectUser = _Paths.authSelectUser;
  static const authLogin = _Paths.authLogin;
  static const authRegister = _Paths.authRegister;
  static const authForgotPassword = _Paths.authForgotPassword;

  static const profile = _Paths.profile;

  static const jobSeekerDashboard = _Paths.jobSeeker + _Paths.dashboard;
  static const jobSeekerCongratulations =
      _Paths.jobSeeker + _Paths.jobSeekerCongratulations;
  static const jobSeekerJobDetails = _Paths.jobSeeker + _Paths.jobDetails;
  static const jobSeekerApplyJob = _Paths.jobSeeker + _Paths.applyJob;
  static const jobSeekerMyApplications =
      _Paths.jobSeeker + _Paths.myApplications;

  static const companyDashboard = _Paths.company + _Paths.dashboard;
  static const companyPostJob = _Paths.company + _Paths.postJob;

  static const jobSeekerNotifications = _Paths.jobSeeker + _Paths.notifications;
  static const jobSeekerSavedJobs = _Paths.jobSeeker + _Paths.savedJobs;
  static const jobSeekerChat = _Paths.jobSeeker + _Paths.chat;
  static const jobSeekerChatDetails = _Paths.jobSeeker + _Paths.chatDetails;
  static const jobSeekerSearchJobs = _Paths.jobSeeker + _Paths.searchJobs;

  static const mainWrapper = _Paths.mainWrapper;

  static const applicationReview = _Paths.applicationReview;
  static const applicationList = _Paths.applicationList;

  static const companyMainWrapper = _Paths.companyMainWrapper;
  static const companyChat = _Paths.companyChat;
  static const companyProfile = _Paths.companyProfile;
  static const companyChatDetails = _Paths.companyChatDetails;
  static const companyNotifications = _Paths.companyNotifications;

  static const pdfViewer = _Paths.pdfViewer;
}

abstract class _Paths {
  _Paths._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const authSelectUser = '/select-user';
  static const authLogin = '/login';
  static const authRegister = '/register';
  static const authForgotPassword = '/forgot-password';

  static const jobSeeker = '/job-seeker';
  static const company = '/company';

  static const dashboard = '/dashboard';
  static const jobSeekerCongratulations = '/congratulations';
  static const jobDetails = '/job-details';
  static const applyJob = '/apply-job';
  static const profile = '/profile';
  static const myApplications = '/my-applications';
  static const postJob = '/post-job';
  static const notifications = '/notifications';
  static const savedJobs = '/saved-jobs';
  static const chat = '/chat';
  static const chatDetails = '/chat-details';
  static const mainWrapper = '/main-wrapper';
  static const applicationReview = '/application-review';
  static const applicationList = '/application-list';
  static const companyMainWrapper = '/company-main-wrapper';
  static const companyChat = '/company-chat';
  static const companyProfile = '/company-profile';
  static const companyChatDetails = '/company-chat-details';
  static const companyNotifications = '/company-notifications';
  static const searchJobs = '/search-jobs';
  static const pdfViewer = '/pdf-viewer';
}
