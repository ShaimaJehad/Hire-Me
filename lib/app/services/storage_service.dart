import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppUserRole { company, jobSeeker }

extension AppUserRoleX on AppUserRole {
  String get value => this == AppUserRole.company ? 'company' : 'jobSeeker';
}

class StorageService extends GetxService {
  static const String _firstTimeKey = 'isFirstTime';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userRoleKey = 'userRole';
  static const String _userIdKey = 'userId';
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _companyIdKey = 'companyId';
  static const String _jobSeekerIdKey = 'jobSeekerId';

  late final SharedPreferences _prefs;

  static StorageService get to => Get.find<StorageService>();

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  static String? normalizeRole(String? role) {
    switch (role?.trim().toLowerCase()) {
      case 'company':
        return AppUserRole.company.value;
      case 'job_seeker':
      case 'jobseeker':
      case 'job seeker':
        return AppUserRole.jobSeeker.value;
      default:
        return null;
    }
  }

  bool get isFirstTime => _prefs.getBool(_firstTimeKey) ?? true;
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;
  String? get userRole => normalizeRole(_prefs.getString(_userRoleKey));
  String? get userId => _prefs.getString(_userIdKey);
  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  String? get companyId => _prefs.getString(_companyIdKey);
  String? get jobSeekerId => _prefs.getString(_jobSeekerIdKey);

  Future<void> setFirstTimeSeen() async {
    await _prefs.setBool(_firstTimeKey, false);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }

  Future<void> saveAuthSession({
    required String userId,
    required String role,
    String? accessToken,
    String? refreshToken,
    String? companyId,
    String? jobSeekerId,
  }) async {
    final normalizedRole = normalizeRole(role);
    if (normalizedRole == null) {
      throw ArgumentError.value(role, 'role', 'Unsupported user role');
    }

    await _prefs.setBool(_firstTimeKey, false);
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userRoleKey, normalizedRole);
    await _prefs.setString(_userIdKey, userId);

    if (accessToken != null && accessToken.isNotEmpty) {
      await _prefs.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }

    if (normalizedRole == AppUserRole.company.value) {
      await _prefs.setString(_companyIdKey, companyId ?? userId);
      await _prefs.remove(_jobSeekerIdKey);
    } else {
      await _prefs.setString(_jobSeekerIdKey, jobSeekerId ?? userId);
      await _prefs.remove(_companyIdKey);
    }
  }

  Future<void> clearAuthSession() async {
    await _prefs.setBool(_isLoggedInKey, false);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_companyIdKey);
    await _prefs.remove(_jobSeekerIdKey);
  }

  Future<void> markOnboardingComplete() => setFirstTimeSeen();
}
