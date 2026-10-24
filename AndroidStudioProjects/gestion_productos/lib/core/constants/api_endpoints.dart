class ApiEndpoints {
  // Ajusta la IP según tu entorno (10.0.2.2 para Android Emulator, localhost para iOS)
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const String productos = '$baseUrl/productos';
  static const String categorias = '$baseUrl/categorias';
}