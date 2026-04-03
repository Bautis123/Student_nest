class AppConstants {
  // API base URL - points to your local backend for now
  static const String baseUrl = 'http://192.168.52.17:5000/api';

  // App info
  static const String appName = 'Student Nest';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Map defaults - centered on UNZA
  static const double defaultLat = -15.414429;
  static const double defaultLng = 28.311788;
  static const double defaultZoom = 14.0;
}
