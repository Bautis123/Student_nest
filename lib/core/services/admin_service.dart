import '../network/api_client.dart';

class AdminService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getStats() async {
    return await _client.get('/admin/stats', auth: true);
  }

  Future<List<dynamic>> getLandlords() async {
    final data = await _client.get('/admin/landlords', auth: true);
    return data['landlords'];
  }

  Future<Map<String, dynamic>> updateLandlordStatus(
    String id,
    bool isApproved,
  ) async {
    return await _client.patch('/admin/landlords/$id', {
      'is_approved': isApproved,
    }, auth: true);
  }

  Future<Map<String, dynamic>> updateLandlordDetails(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _client.patch('/admin/landlords/$id', data, auth: true);
  }

  Future<Map<String, dynamic>> resetLandlordPassword(
    String id,
    String password,
  ) async {
    return await _client.patch('/admin/landlords/$id/reset-password', {
      'password': password,
    }, auth: true);
  }

  Future<Map<String, dynamic>> deleteLandlord(String id) async {
    return await _client.delete('/admin/landlords/$id', auth: true);
  }

  Future<List<dynamic>> getProperties({String? status}) async {
    String path = '/admin/properties';
    if (status != null) path += '?status=$status';
    final data = await _client.get(path, auth: true);
    return data['properties'];
  }

  Future<Map<String, dynamic>> updatePropertyStatus(
    String id,
    bool isApproved,
  ) async {
    return await _client.patch('/admin/properties/$id', {
      'is_approved': isApproved,
    }, auth: true);
  }

  Future<Map<String, dynamic>> deleteProperty(String id) async {
    return await _client.delete('/admin/properties/$id', auth: true);
  }

  Future<List<dynamic>> getPayments() async {
    final data = await _client.get('/admin/payments', auth: true);
    return data['payments'];
  }

  Future<Map<String, dynamic>> recordPayment(Map<String, dynamic> data) async {
    return await _client.post('/admin/payments', data, auth: true);
  }
}
