class Categoria {
  final String id;
  final String nombre;
  final String descripcion;

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
  };
}