import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';

class CsvExporter {
  static Future<void> exportAndShareBooks() async {
    final books = await AppDatabase.instance.getBooks();

    // Encabezados de las columnas
    List<List<dynamic>> rows = [
      ['ID', 'Título', 'Autor', 'ISBN', 'Año']
    ];

    // Mapeo de cada registro a una fila del CSV
    for (var book in books) {
      rows.add([
        book.id,
        book.title,
        book.author,
        book.isbn,
        book.year,
      ]);
    }

    // Convertir la lista a texto plano en formato CSV
    String csvData = const ListToCsvConverter().convert(rows);

    // Obtener el directorio temporal del dispositivo
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/libros_registrados.csv';
    final file = File(path);

    // Escribir el archivo en disco
    await file.writeAsString(csvData);

    // Desplegar el selector nativo para compartir/guardar
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Exportación de registros en formato CSV',
    );
  }
}