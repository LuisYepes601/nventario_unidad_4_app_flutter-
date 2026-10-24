import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'category_model.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  // Inyección de dependencias para permitir mocks en pruebas unitarias
  CategoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET - Obtener la lista completa de categorías
  Future<List<Category>> getCategories() async {
    final List<dynamic> data = await _apiClient.get(ApiEndpoints.categorias);
    return data
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST - Crear una nueva categoría en el backend
  Future<Category> createCategory(Category category) async {
    final Map<String, dynamic> body = category.toJson();
    final data = await _apiClient.post(ApiEndpoints.categorias, body);
    return Category.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE - Eliminar una categoría por su ID
  Future<bool> deleteCategory(String id) async {
    await _apiClient.delete('${ApiEndpoints.categorias}/$id');
    return true;
  }
}