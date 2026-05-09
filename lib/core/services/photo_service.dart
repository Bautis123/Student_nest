import 'dart:io';
import '../network/api_client.dart';

class PhotoService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> uploadPhotos(String propertyId, List<File> files, {bool isCover = false}) async {
    return await _client.uploadFiles('/photos/$propertyId', files, {
      'is_cover': isCover ? 'true' : 'false',
    }, auth: true);
  }

  Future<Map<String, dynamic>> deletePhoto(String photoId) async {
    return await _client.delete('/photos/$photoId', auth: true);
  }

  Future<Map<String, dynamic>> setCoverPhoto(
    String propertyId,
    String photoId,
  ) async {
    return await _client.patch('/photos/$photoId/cover', {
      'property_id': propertyId,
    }, auth: true);
  }
}
