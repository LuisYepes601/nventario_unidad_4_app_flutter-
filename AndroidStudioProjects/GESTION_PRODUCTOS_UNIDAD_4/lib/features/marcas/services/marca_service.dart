import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../models/marca.dart';

class MarcaService {
  final String _url = '${ApiConfig.baseUrl}/marcas';

  // Obtener todas las marcas
  Future<List<Marca>> getMarcas() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Marca.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener una marca por ID
  Future<Marca?> getMarcaById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_url/$id'));

      if (response.statusCode == 200) {
        return Marca.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Crear una nueva marca
  Future<bool> createMarca(Marca marca) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(marca.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Actualizar una marca existente
  Future<bool> updateMarca(String id, Marca marca) async {
    try {
      final response = await http.put(
        Uri.parse('$_url/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(marca.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Eliminar una marca
  Future<bool> deleteMarca(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_url/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}