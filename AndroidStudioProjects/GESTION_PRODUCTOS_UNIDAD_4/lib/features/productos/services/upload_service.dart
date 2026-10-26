import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class UploadService {
  static Future<String?> subirImagen(File file) async {
    try {
      // Endpoint de subida
      final uri = Uri.parse('${ApiConfig.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['url'] as String?; // Devuelve la URL de Cloudinary
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}