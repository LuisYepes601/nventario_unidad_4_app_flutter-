import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/producto.dart';

class CsvExporter {
  static Future<File> exportar(List<Producto> productos) async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/exportados');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final archivo = File(
      '${carpeta.path}/inventario_${DateTime.now().millisecondsSinceEpoch}.csv',
    );

    final buffer = StringBuffer();
    buffer.writeln('Nombre,Categoria,Precio,Cantidad,EmailProveedor,FechaIngreso');
    for (final p in productos) {
      buffer.writeln(
        '${p.nombre},${p.categoria},${p.precio},${p.cantidad},${p.emailProveedor},${p.fechaIngreso}',
      );
    }

    await archivo.writeAsString(buffer.toString());
    return archivo;
  }

  static Future<void> exportarYCompartir(List<Producto> productos) async {
    final archivo = await exportar(productos);
    await Share.shareXFiles(
      [XFile(archivo.path)],
      text: 'Inventario exportado desde InventarioApp',
    );
  }
}