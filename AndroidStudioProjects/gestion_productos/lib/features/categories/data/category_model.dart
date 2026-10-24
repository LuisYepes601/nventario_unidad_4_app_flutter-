class Category {
  final String id;
  final String nombre;
  final String? codigo;

  Category({required this.id, required this.nombre, this.codigo});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'codigo': codigo,
  };
}