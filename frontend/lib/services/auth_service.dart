class AuthService {
  static String? userId;
  static String? role;

  static void setUser({
    required String id,
    required String userRole,
  }) {
    userId = id;
    role = userRole;
  }

  static bool get isLoggedIn {
    return userId != null;
  }

  static void logout() {
    userId = null;
    role = null;
  }
}