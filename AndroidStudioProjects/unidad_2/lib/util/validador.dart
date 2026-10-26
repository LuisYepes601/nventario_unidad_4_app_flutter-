class Validador {
  static String? campoObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(valor.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? precio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'El precio es obligatorio';
    final n = double.tryParse(valor);
    if (n == null || n <= 0) return 'Ingresa un precio mayor a 0';
    return null;
  }

  static String? cantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'La cantidad es obligatoria';
    final n = int.tryParse(valor);
    if (n == null || n < 0) return 'Ingresa una cantidad válida (0 o más)';
    return null;
  }
}