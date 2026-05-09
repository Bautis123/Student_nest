import 'dart:io';

import 'package:student_nest/core/network/api_client.dart';
import 'package:student_nest/core/services/auth_service.dart';
import 'package:student_nest/core/services/photo_service.dart';
import 'package:student_nest/core/services/property_service.dart';
import 'package:student_nest/core/services/storage_service.dart';

import '../models/property.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final ApiClient _client = ApiClient();
  final AuthService _auth = AuthService();
  final PhotoService _photos = PhotoService();
  final PropertyService _properties = PropertyService();
  final StorageService _storage = StorageService();

  Future<String?> getToken() => _storage.getToken();

  Future<void> saveToken(String token) => _storage.saveToken(token);

  Future<void> saveUser(Map<String, dynamic> user) => _storage.saveUser(user);

  Future<User?> getUser() => _storage.getUser();

  Future<void> logout() => _storage.clearAll();

  Future<Map<String, dynamic>> login(String phone, String password) {
    return _auth.login(phone, password);
  }

  Future<Map<String, dynamic>> register(
    String fullName,
    String phone,
    String? email,
    String password,
  ) {
    return _auth.register(fullName, phone, email, password);
  }

  Future<List<Property>> getProperties({
    String? schoolId,
    double? minPrice,
    double? maxPrice,
  }) {
    return _properties.getProperties(
      schoolId: schoolId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<Property> getPropertyById(String id) => _properties.getPropertyById(id);

  Future<void> trackContactClick(String propertyId) {
    return _properties.trackContactClick(propertyId);
  }

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) {
    return _properties.createProperty(data);
  }

  Future<Map<String, dynamic>> addRooms(
    String propertyId,
    List<Map<String, dynamic>> rooms,
  ) {
    return _properties.addRooms(propertyId, rooms);
  }

  Future<List<Property>> getMyProperties() => _properties.getMyProperties();

  Future<List<Map<String, dynamic>>> getSchools() => _properties.getSchools();

  Future<Map<String, dynamic>> updateProperty(
    String id,
    Map<String, dynamic> data,
  ) {
    return _properties.updateProperty(id, data);
  }

  Future<Map<String, dynamic>> deleteProperty(String id) {
    return _properties.deleteProperty(id);
  }

  Future<Map<String, dynamic>> togglePropertyActive(
    String id,
    bool isActive,
  ) {
    return _properties.toggleActive(id, isActive);
  }

  Future<Map<String, dynamic>> deletePhoto(String photoId) {
    return _photos.deletePhoto(photoId);
  }

  Future<Map<String, dynamic>> uploadPhotos(String propertyId, List<File> files, {bool isCover = false}) {
    return _photos.uploadPhotos(propertyId, files, isCover: isCover);
  }

  Future<Map<String, dynamic>> setCoverPhoto(
    String propertyId,
    String photoId,
  ) {
    return _photos.setCoverPhoto(propertyId, photoId);
  }

  Future<Map<String, dynamic>> updateRoomAvailability(
    String roomId,
    int availableRooms,
  ) {
    return _properties.updateRoomAvailability(roomId, availableRooms);
  }

  Future<Map<String, dynamic>> getAdminStats() {
    return _client.get('/admin/stats', auth: true);
  }

  Future<List<dynamic>> getLandlords() async {
    final data = await _client.get('/admin/landlords', auth: true);
    return data['landlords'];
  }

  Future<Map<String, dynamic>> updateLandlordStatus(
    String id,
    bool isApproved,
  ) {
    return _client.patch('/admin/landlords/$id', {
      'is_approved': isApproved,
    }, auth: true);
  }

  Future<List<dynamic>> getAdminProperties({String? status}) async {
    var path = '/admin/properties';
    if (status != null) {
      path += '?${Uri(queryParameters: {'status': status}).query}';
    }
    final data = await _client.get(path, auth: true);
    return data['properties'];
  }

  Future<Map<String, dynamic>> updatePropertyStatus(
    String id,
    bool isApproved,
  ) {
    return _client.patch('/admin/properties/$id', {
      'is_approved': isApproved,
    }, auth: true);
  }

  Future<Map<String, dynamic>> updateLandlordDetails(
    String id,
    Map<String, dynamic> data,
  ) {
    return _client.patch('/admin/landlords/$id', data, auth: true);
  }

  Future<Map<String, dynamic>> resetLandlordPassword(
    String id,
    String newPassword,
  ) {
    return _client.patch('/admin/landlords/$id/reset-password', {
      'password': newPassword,
    }, auth: true);
  }

  Future<Map<String, dynamic>> deleteLandlord(String id) {
    return _client.delete('/admin/landlords/$id', auth: true);
  }

  Future<List<dynamic>> getPayments() async {
    final data = await _client.get('/admin/payments', auth: true);
    return data['payments'];
  }

  Future<Map<String, dynamic>> recordPayment(
    Map<String, dynamic> paymentData,
  ) {
    return _client.post('/admin/payments', paymentData, auth: true);
  }
}
