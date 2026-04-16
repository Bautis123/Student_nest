import '../network/api_client.dart';
import 'storage_service.dart';
import '../../models/user.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String phone, String password) async {
    return await _client.post('/auth/login', {
      'phone': phone,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(
    String fullName,
    String phone,
    String? email,
    String password,
  ) async {
    return await _client.post('/auth/register', {
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    });
  }

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    await _storage.saveToken(token);
    await _storage.saveUser(user);
  }

  Future<User?> getUser() => _storage.getUser();
  Future<String?> getToken() => _storage.getToken();
  Future<void> logout() => _storage.clearAll();
}
