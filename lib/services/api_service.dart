import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/property.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // Save user
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user));
  }

  // Get stored user
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConstants.userKey);
    if (userStr == null) return null;
    return User.fromJson(jsonDecode(userStr));
  }

  // Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  // Auth headers
  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTH ──────────────────────────────────────────────────
  // Login user
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Register new user
  Future<Map<String, dynamic>> register(
    String fullName,
    String phone,
    String? email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── PROPERTIES ────────────────────────────────────────────

  // Get properties with optional filters
  Future<List<Property>> getProperties({
    String? schoolId,
    double? minPrice,
    double? maxPrice,
  }) async {
    String url = '${AppConstants.baseUrl}/properties';
    final params = <String, String>{};
    if (schoolId != null) params['school_id'] = schoolId;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    return (data['properties'] as List)
        .map((p) => Property.fromJson(p))
        .toList();
  }

  // Get property details by ID
  Future<Property> getPropertyById(String id) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/properties/$id'),
    );
    final data = jsonDecode(response.body);
    return Property.fromJson(data['property']);
  }

  // Track contact clicks for analytics
  Future<void> trackContactClick(String propertyId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/properties/$propertyId/contact'),
    );
  }

  // Create new property
  Future<Map<String, dynamic>> createProperty(
    Map<String, dynamic> propertyData,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/properties'),
      headers: headers,
      body: jsonEncode(propertyData),
    );
    return jsonDecode(response.body);
  }

  // Add rooms to a property
  Future<Map<String, dynamic>> addRooms(
    String propertyId,
    List<Map<String, dynamic>> rooms,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/properties/$propertyId/rooms'),
      headers: headers,
      body: jsonEncode({'rooms': rooms}),
    );
    return jsonDecode(response.body);
  }

  // Get properties of logged in landlord
  Future<List<Property>> getMyProperties() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/properties/landlord/my-properties'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return (data['properties'] as List)
        .map((p) => Property.fromJson(p))
        .toList();
  }

  // Get list of schools for filtering
  Future<List<Map<String, dynamic>>> getSchools() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/properties/schools'),
    );
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['schools']);
  }

  // ── ADMIN ─────────────────────────────────────────────────
  // Get dashboard stats for admin
  Future<Map<String, dynamic>> getAdminStats() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/admin/stats'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Get pending landlords for admin dashboard
  Future<List<dynamic>> getLandlords() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/admin/landlords'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['landlords'];
  }

  // Update landlord approval status
  Future<Map<String, dynamic>> updateLandlordStatus(
    String id,
    bool isApproved,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/admin/landlords/$id'),
      headers: headers,
      body: jsonEncode({'is_approved': isApproved}),
    );
    return jsonDecode(response.body);
  }

  // Get pending properties for admin dashboard
  Future<List<dynamic>> getAdminProperties({String? status}) async {
    final headers = await _authHeaders();
    String url = '${AppConstants.baseUrl}/admin/properties';
    if (status != null) url += '?status=$status';
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = jsonDecode(response.body);
    return data['properties'];
  }

  // Update property approval status
  Future<Map<String, dynamic>> updatePropertyStatus(
    String id,
    bool isApproved,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/admin/properties/$id'),
      headers: headers,
      body: jsonEncode({'is_approved': isApproved}),
    );
    return jsonDecode(response.body);
  }

  // Update property details
  Future<Map<String, dynamic>> updateProperty(
    String id,
    Map<String, dynamic> data,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/properties/$id'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Delete property
  Future<Map<String, dynamic>> deleteProperty(String id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/properties/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Toggle property active status
  Future<Map<String, dynamic>> togglePropertyActive(
    String id,
    bool isActive,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/properties/$id'),
      headers: headers,
      body: jsonEncode({'is_active': isActive}),
    );
    return jsonDecode(response.body);
  }

  // Delete photo
  Future<Map<String, dynamic>> deletePhoto(String photoId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/photos/$photoId'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // Upload photos from phone
  Future<Map<String, dynamic>> uploadPhotos(
    String propertyId,
    List<File> files,
  ) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/photos/$propertyId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['is_cover'] = 'false';

    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  // Set cover photo
  Future<Map<String, dynamic>> setCoverPhoto(
    String propertyId,
    String photoId,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/photos/$photoId/cover'),
      headers: headers,
      body: jsonEncode({'property_id': propertyId}),
    );
    return jsonDecode(response.body);
  }

  // Update room availability
  Future<Map<String, dynamic>> updateRoomAvailability(
    String roomId,
    int availableRooms,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/properties/rooms/$roomId'),
      headers: headers,
      body: jsonEncode({'available_rooms': availableRooms}),
    );
    return jsonDecode(response.body);
  }

  // ── LANDLORD MANAGEMENT (ADMIN) ────────────────────────────────────────────

  // Update landlord details (admin)
  Future<Map<String, dynamic>> updateLandlordDetails(
    String id,
    Map<String, dynamic> data,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/admin/landlords/$id'),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // Reset landlord password
  Future<Map<String, dynamic>> resetLandlordPassword(
    String id,
    String newPassword,
  ) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/admin/landlords/$id/reset-password'),
      headers: headers,
      body: jsonEncode({'password': newPassword}),
    );
    return jsonDecode(response.body);
  }

  // Delete landlord
  Future<Map<String, dynamic>> deleteLandlord(String id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/admin/landlords/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // ── PAYMENT MANAGEMENT (ADMIN) ────────────────────────────────────────────
  Future<List<dynamic>> getPayments() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/admin/payments'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['payments'];
  }

  // Record a new payment
  Future<Map<String, dynamic>> recordPayment(
    Map<String, dynamic> paymentData,
  ) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/admin/payments'),
      headers: headers,
      body: jsonEncode(paymentData),
    );
    return jsonDecode(response.body);
  }
}
