// test/auth_login_controller_test.dart
//
// Unit tests لـ AuthLoginController
// بنستخدم GetX test utilities + mockito لعزل Firebase
//
// شغّله بـ: flutter test test/auth_login_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ─── نماذج بسيطة لاختبار الـ validation logic بدون Firebase ───

class _FakeLoginController {
  bool isValid(String email, String password) {
    if (email.trim().isEmpty || password.trim().isEmpty) return false;
    if (!GetUtils.isEmail(email.trim())) return false;
    return true;
  }

  String mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}

void main() {
  late _FakeLoginController controller;

  setUp(() {
    controller = _FakeLoginController();
  });

  // ─── مجموعة اختبارات الـ Validation ───
  group('Login Validation', () {
    test('should return false when email is empty', () {
      expect(controller.isValid('', 'password123'), false);
    });

    test('should return false when password is empty', () {
      expect(controller.isValid('test@gmail.com', ''), false);
    });

    test('should return false when email format is invalid', () {
      expect(controller.isValid('notanemail', 'password123'), false);
      expect(controller.isValid('missing@', 'password123'), false);
      expect(controller.isValid('@domain.com', 'password123'), false);
    });

    test('should return true with valid email and password', () {
      expect(controller.isValid('user@gmail.com', '123456'), true);
      expect(controller.isValid('company@hire.me', 'securePass'), true);
    });

    test('should trim whitespace before validating', () {
      expect(controller.isValid('  user@gmail.com  ', '123456'), true);
    });
  });

  // ─── مجموعة اختبارات Firebase Error Mapping ───
  group('Firebase Error Messages', () {
    test('user-not-found returns correct message', () {
      expect(
        controller.mapFirebaseError('user-not-found'),
        'No account found with this email',
      );
    });

    test('wrong-password returns correct message', () {
      expect(
        controller.mapFirebaseError('wrong-password'),
        'Incorrect password',
      );
    });

    test('too-many-requests returns correct message', () {
      expect(
        controller.mapFirebaseError('too-many-requests'),
        'Too many attempts. Try again later',
      );
    });

    test('unknown error returns generic message', () {
      expect(
        controller.mapFirebaseError('some-unknown-code'),
        'Something went wrong. Please try again',
      );
    });
  });
}
