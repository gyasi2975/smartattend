import 'package:flutter/material.dart';
import 'user_model.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  UserRole? get userRole => _currentUser?.role;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setUserId(String id) {
    // This method is kept for backward compatibility
    // In the new system, use setUser() instead
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(id: id);
      notifyListeners();
    }
  }

  void updateUserBiometricPreference(String? method) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(preferredBiometricMethod: method);
      notifyListeners();
    }
  }

  void updateBiometricEnrollment({bool? face, bool? fingerprint}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        faceEnrolled: face,
        fingerprintEnrolled: fingerprint,
      );
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  bool get isStudent => _currentUser?.role == UserRole.student;
  bool get isLecturer => _currentUser?.role == UserRole.lecturer;
  bool get isLoggedIn => _currentUser != null;
}
