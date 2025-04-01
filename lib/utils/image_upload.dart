import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  static ImageUploadService? _instance;
  ImageUploadService._();
  static ImageUploadService getInstance() {
    _instance ??= ImageUploadService._();
    return _instance!;
  }

  Future<String> uploadImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse('https://api.imgur.com/3/image');
    final request = http.MultipartRequest('POST', url);
    request.fields['image'] = base64Image;
    final accessToken = '825c6d32b1d3b4781692a8648e87273cd0889cf9';
    request.headers['Authorization'] = 'Bearer $accessToken';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success']) {
        return json['data']['link'];
      } else {
        throw Exception('Image upload failed.');
      }
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
