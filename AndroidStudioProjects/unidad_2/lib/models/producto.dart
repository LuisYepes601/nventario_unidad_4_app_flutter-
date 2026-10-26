class Producto {
  final int? id;
  final String nombre;
  final String categoria;
  final double precio;
  final int cantidad;
  final String emailProveedor;
  final String fechaIngreso;

  Producto({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.cantidad,
    required this.emailProveedor,
    required this.fechaIngreso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'cantidad': cantidad,
      'emailProveedor': emailProveedor,
      'fechaIngreso': fechaIngreso,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      precio: map['precio'] as double,
      cantidad: map['cantidad'] as int,
      emailProveedor: map['emailProveedor'] as String,
      fechaIngreso: map['fechaIngreso'] as String,
    );
  }
}