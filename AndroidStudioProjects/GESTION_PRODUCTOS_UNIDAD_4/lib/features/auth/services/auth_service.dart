import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../models/usuario.dart';

class AuthService {
  Future<Usuario?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data['usuario']);
    }
    return null;
  }

  Future<bool> registro(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }
}