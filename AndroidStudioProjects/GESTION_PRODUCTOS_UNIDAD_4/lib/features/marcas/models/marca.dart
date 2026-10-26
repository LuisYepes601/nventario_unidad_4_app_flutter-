class Marca {
  final String id;
  final String nombre;
  final String paisOrigen;

  Marca({
    required this.id,
    required this.nombre,
    required this.paisOrigen,
  });

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      paisOrigen: json['paisOrigen'] ?? 'Desconocido',
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'paisOrigen': paisOrigen,
  };
}