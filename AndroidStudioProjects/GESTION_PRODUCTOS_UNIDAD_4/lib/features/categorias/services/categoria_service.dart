import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../models/categoria.dart';

class CategoriaService {
  final String _url = '${ApiConfig.baseUrl}/categorias';

  // Obtener la lista de categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Categoria.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener una categoría específica por ID
  Future<Categoria?> getCategoriaById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_url/$id'));

      if (response.statusCode == 200) {
        return Categoria.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Crear una nueva categoría
  Future<bool> createCategoria(Categoria categoria) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Actualizar una categoría existente
  Future<bool> updateCategoria(String id, Categoria categoria) async {
    try {
      final response = await http.put(
        Uri.parse('$_url/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(categoria.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Eliminar una categoría
  Future<bool> deleteCategoria(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_url/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}