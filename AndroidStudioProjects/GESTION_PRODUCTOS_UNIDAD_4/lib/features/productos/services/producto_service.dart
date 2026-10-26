import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../models/producto.dart';

class ProductoService {
  final String _url = '${ApiConfig.baseUrl}/productos';

  Future<List<Producto>> getProductos() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Producto.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error al obtener productos: $e');
      return [];
    }
  }

  // Crear producto enviando Multipart con logs explícitos de error
  Future<bool> createProducto(Producto prod, {File? imagenFile}) async {
    try {
      print('🚀 Enviando POST a: $_url');

      if (imagenFile != null) {
        final request = http.MultipartRequest('POST', Uri.parse(_url));

        request.fields['nombre'] = prod.nombre;
        request.fields['sku'] = prod.sku;
        request.fields['precio'] = prod.precio.toString();
        request.fields['stock'] = prod.stock.toString();
        request.fields['descripcion'] = prod.descripcion;
        request.fields['categoria'] = prod.categoriaId;
        request.fields['marca'] = prod.marcaId;

        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagenFile.path),
        );

        // Timeout de 45s por si Render está saliendo de suspensión
        final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
        final responseBody = await streamedResponse.stream.bytesToString();

        print('📌 [CREAR MULTIPART] Status: ${streamedResponse.statusCode}');
        print('📌 [CREAR MULTIPART] Respuesta Backend: $responseBody');

        return streamedResponse.statusCode == 201;
      } else {
        final response = await http.post(
          Uri.parse(_url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(prod.toJson()),
        ).timeout(const Duration(seconds: 45));

        print('📌 [CREAR JSON] Status: ${response.statusCode}');
        print('📌 [CREAR JSON] Respuesta Backend: ${response.body}');

        return response.statusCode == 201;
      }
    } catch (e) {
      print('💥 EXCEPCIÓN AL CREAR PRODUCTO: $e');
      return false;
    }
  }

  // Actualizar producto enviando Multipart con logs explícitos de error
  Future<bool> updateProducto(String id, Producto prod, {File? imagenFile}) async {
    try {
      if (imagenFile != null) {
        final request = http.MultipartRequest('PUT', Uri.parse('$_url/$id'));

        request.fields['nombre'] = prod.nombre;
        request.fields['sku'] = prod.sku;
        request.fields['precio'] = prod.precio.toString();
        request.fields['stock'] = prod.stock.toString();
        request.fields['descripcion'] = prod.descripcion;
        request.fields['categoria'] = prod.categoriaId;
        request.fields['marca'] = prod.marcaId;

        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagenFile.path),
        );

        final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
        final responseBody = await streamedResponse.stream.bytesToString();

        print('📌 [UPDATE MULTIPART] Status: ${streamedResponse.statusCode}');
        print('📌 [UPDATE MULTIPART] Respuesta Backend: $responseBody');

        return streamedResponse.statusCode == 200;
      } else {
        final response = await http.put(
          Uri.parse('$_url/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(prod.toJson()),
        ).timeout(const Duration(seconds: 45));

        print('📌 [UPDATE JSON] Status: ${response.statusCode}');
        print('📌 [UPDATE JSON] Respuesta Backend: ${response.body}');

        return response.statusCode == 200;
      }
    } catch (e) {
      print('💥 EXCEPCIÓN AL ACTUALIZAR PRODUCTO: $e');
      return false;
    }
  }

  Future<bool> deleteProducto(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_url/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al eliminar producto: $e');
      return false;
    }
  }
}