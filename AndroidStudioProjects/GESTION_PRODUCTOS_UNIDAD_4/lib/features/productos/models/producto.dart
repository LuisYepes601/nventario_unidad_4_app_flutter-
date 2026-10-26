import '../../categorias/models/categoria.dart';
import '../../marcas/models/marca.dart';

class Producto {
  final String? id;
  final String nombre;
  final String sku;
  final double precio;
  final int stock;
  final String descripcion;
  final String imagenUrl;
  final dynamic categoria; // Puede contener el objeto Categoria o el String ID
  final dynamic marca;     // Puede contener el objeto Marca o el String ID

  Producto({
    this.id,
    required this.nombre,
    required this.sku,
    required this.precio,
    required this.stock,
    required this.descripcion,
    required this.imagenUrl,
    required this.categoria,
    required this.marca,
  });

  // Obtiene el ID de la categoría sea objeto o String
  String get categoriaId {
    if (categoria is Categoria) return (categoria as Categoria).id;
    return categoria?.toString() ?? '';
  }

  // Obtiene el nombre de la categoría si viene poblada desde la API
  String get categoriaNombre {
    if (categoria is Categoria) return (categoria as Categoria).nombre;
    return 'Sin categoría';
  }

  // Obtiene el ID de la marca sea objeto o String
  String get marcaId {
    if (marca is Marca) return (marca as Marca).id;
    return marca?.toString() ?? '';
  }

  // Obtiene el nombre de la marca si viene poblada desde la API
  String get marcaNombre {
    if (marca is Marca) return (marca as Marca).nombre;
    return 'Sin marca';
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['_id'],
      nombre: json['nombre'] ?? '',
      sku: json['sku'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
      categoria: json['categoria'] is Map
          ? Categoria.fromJson(json['categoria'])
          : json['categoria'],
      marca: json['marca'] is Map
          ? Marca.fromJson(json['marca'])
          : json['marca'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'sku': sku,
    'precio': precio,
    'stock': stock,
    'descripcion': descripcion,
    'imagenUrl': imagenUrl,
    'categoria': categoriaId,
    'marca': marcaId,
  };
}