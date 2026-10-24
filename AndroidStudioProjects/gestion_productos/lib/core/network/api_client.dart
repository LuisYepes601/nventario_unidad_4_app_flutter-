import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers);
    return _processResponse(response);
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String url) async {
    final response = await _client.delete(Uri.parse(url), headers: _headers);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return true;
      return jsonDecode(response.body);
    } else {
      throw Exception('Error servidor [${response.statusCode}]: ${response.body}');
    }
  }
}