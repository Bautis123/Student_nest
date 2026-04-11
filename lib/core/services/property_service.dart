import '../network/api_client.dart';
import '../../shared/models/property.dart';

class PropertyService {
  final ApiClient _client = ApiClient();

  Future<List<Property>> getProperties({
    String? schoolId,
    double? minPrice,
    double? maxPrice,
  }) async {
    String path = '/properties';
    final params = <String, String>{};
    if (schoolId != null) params['school_id'] = schoolId;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final data = await _client.get(path);
    return (data['properties'] as List)
        .map((p) => Property.fromJson(p))
        .toList();
  }

  Future<Property> getPropertyById(String id) async {
    final data = await _client.get('/properties/$id');
    return Property.fromJson(data['property']);
  }

  Future<void> trackContactClick(String propertyId) async {
    await _client.post('/properties/$propertyId/contact', {});
  }

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) async {
    return await _client.post('/properties', data, auth: true);
  }

  Future<Map<String, dynamic>> updateProperty(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _client.patch('/properties/$id', data, auth: true);
  }

  Future<Map<String, dynamic>> deleteProperty(String id) async {
    return await _client.delete('/properties/$id', auth: true);
  }

  Future<Map<String, dynamic>> toggleActive(String id, bool isActive) async {
    return await _client.patch('/properties/$id', {
      'is_active': isActive,
    }, auth: true);
  }

  Future<List<Property>> getMyProperties() async {
    final data = await _client.get(
      '/properties/landlord/my-properties',
      auth: true,
    );
    return (data['properties'] as List)
        .map((p) => Property.fromJson(p))
        .toList();
  }

  Future<Map<String, dynamic>> addRooms(
    String propertyId,
    List<Map<String, dynamic>> rooms,
  ) async {
    return await _client.post('/properties/$propertyId/rooms', {
      'rooms': rooms,
    }, auth: true);
  }

  Future<Map<String, dynamic>> updateRoomAvailability(
    String roomId,
    int availableRooms,
  ) async {
    return await _client.patch('/properties/rooms/$roomId', {
      'available_rooms': availableRooms,
    }, auth: true);
  }

  Future<List<Map<String, dynamic>>> getSchools() async {
    final data = await _client.get('/properties/schools');
    return List<Map<String, dynamic>>.from(data['schools']);
  }
}
