import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  // Permite inyectar un ApiClient (útil para pruebas unitarias) o usar el por defecto
  ProductRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET - Obtener la lista completa de productos
  Future<List<Product>> getProducts() async {
    final List<dynamic> data = await _apiClient.get(ApiEndpoints.productos);
    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET - Obtener un producto específico por su ID
  Future<Product> getProductById(String id) async {
    final data = await _apiClient.get('${ApiEndpoints.productos}/$id');
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// POST - Crear un nuevo producto asignándole el ID de la categoría
  Future<Product> createProduct(Product product, String categoryId) async {
    final Map<String, dynamic> body = product.toJson(categoryId: categoryId);
    final data = await _apiClient.post(ApiEndpoints.productos, body);
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// PUT - Actualizar un producto existente por ID
  Future<Product> updateProduct(String id, Product product, String categoryId) async {
    final Map<String, dynamic> body = product.toJson(categoryId: categoryId);
    final data = await _apiClient.put('${ApiEndpoints.productos}/$id', body);
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE - Eliminar un producto del inventario
  Future<bool> deleteProduct(String id) async {
    await _apiClient.delete('${ApiEndpoints.productos}/$id');
    return true;
  }
}