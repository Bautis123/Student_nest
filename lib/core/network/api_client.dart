import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _url(String path) => Uri.parse('${AppConstants.baseUrl}$path');

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await http.get(
      _url(path),
      headers: await _headers(auth: auth),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.post(
      _url(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.patch(
      _url(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = false}) async {
    final response = await http.delete(
      _url(path),
      headers: await _headers(auth: auth),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadFiles(
    String path,
    List<File> files,
    Map<String, String> fields, {
    bool auth = false,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest('POST', _url(path));
    if (auth && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    fields.forEach((key, value) => request.fields[key] = value);
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }
}
