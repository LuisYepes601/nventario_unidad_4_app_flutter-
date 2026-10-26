import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/producto.dart';
import '../util/validador.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados')),
      );
      return;
    }

    final producto = Producto(
      nombre: _nombreCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      cantidad: int.parse(_cantidadCtrl.text.trim()),
      emailProveedor: _emailCtrl.text.trim(),
      fechaIngreso: DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertar(producto);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Producto guardado')));
      Navigator.pop(context);
    }
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: const Color(0xFF1565C0)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---- HEADER CON DEGRADADO ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_box_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuevo producto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completa los datos del inventario',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- FORMULARIO ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration:
                        _decoracion('Nombre del producto', Icons.label_outline),
                        validator: Validador.campoObligatorio,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _categoriaCtrl,
                        decoration:
                        _decoracion('Categoría', Icons.category_outlined),
                        validator: Validador.campoObligatorio,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _precioCtrl,
                        decoration:
                        _decoracion('Precio', Icons.attach_money),
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        validator: Validador.precio,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _cantidadCtrl,
                        decoration: _decoracion(
                            'Cantidad en stock', Icons.numbers),
                        keyboardType: TextInputType.number,
                        validator: Validador.cantidad,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _decoracion(
                            'Correo del proveedor', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: Validador.email,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}