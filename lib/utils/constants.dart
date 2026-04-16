class AppConstants {
  // API base URL - points to your local backend for now
  static const String baseUrl = 'http://192.168.66.17:5000/api';

  // App info
  static const String appName = 'Student Nest';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeModeKey = 'theme_mode';

  // Map defaults - centered on UNZA (Great East Road campus area)
  static const double defaultLat = -15.394722;
  static const double defaultLng = 28.332222;
  static const double defaultZoom = 14.0;
  static const String googleMapsApiKey =
      'AIzaSyANlhraCJif7hxb5jwrJJXC-0C0ttB2tJI';
}
