import 'package:gestion_productos/features/categories/data/category_model.dart';

class Product {
  final String? id;
  final String sku;
  final String nombre;
  final String? descripcion;
  final double precioCosto;
  final double precioVenta;
  final int stock;
  final int stockMinimo;
  final String? marca;
  final String? imagenPrincipal;
  final Category? categoria;

  Product({
    this.id,
    required this.sku,
    required this.nombre,
    this.descripcion,
    required this.precioCosto,
    required this.precioVenta,
    required this.stock,
    this.stockMinimo = 5,
    this.marca,
    this.imagenPrincipal,
    this.categoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      sku: json['sku'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioCosto: (json['precioCosto'] ?? 0).toDouble(),
      precioVenta: (json['precioVenta'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      stockMinimo: json['stockMinimo'] ?? 5,
      marca: json['marca'],
      imagenPrincipal: json['imagenPrincipal'],
      categoria: json['categoria'] != null && json['categoria'] is Map<String, dynamic>
          ? Category.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? categoryId}) => {
    'sku': sku,
    'nombre': nombre,
    'descripcion': descripcion,
    'precioCosto': precioCosto,
    'precioVenta': precioVenta,
    'stock': stock,
    'stockMinimo': stockMinimo,
    'marca': marca,
    'imagenPrincipal': imagenPrincipal,
    'categoria': categoryId ?? categoria?.id,
  };
}