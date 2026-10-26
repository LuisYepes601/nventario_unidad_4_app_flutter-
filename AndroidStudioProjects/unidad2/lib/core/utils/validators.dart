class Validators {
  // Valida que un texto no esté vacío
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    return null;
  }

  // Valida que el año sea un número válido de 4 dígitos
  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El año es obligatorio';
    }
    final year = int.tryParse(value);
    if (year == null || year < 1000 || year > DateTime.now().year) {
      return 'Ingresa un año válido (ej. 2024)';
    }
    return null;
  }

  // Valida un formato básico de ISBN
  static String? validateIsbn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El ISBN es obligatorio';
    }
    final cleanIsbn = value.replaceAll('-', '').replaceAll(' ', '');
    if (cleanIsbn.length != 10 && cleanIsbn.length != 13) {
      return 'El ISBN debe tener 10 o 13 dígitos';
    }
    return null;
  }
}