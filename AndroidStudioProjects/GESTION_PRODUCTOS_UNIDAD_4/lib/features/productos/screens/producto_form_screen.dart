import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';
import '../../categorias/models/categoria.dart';
import '../../categorias/services/categoria_service.dart';
import '../../marcas/models/marca.dart';
import '../../marcas/services/marca_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _imagenUrlCtrl;

  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();
  final MarcaService _marcaService = MarcaService();
  final ImagePicker _picker = ImagePicker();

  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];

  String? _categoriaSeleccionadaId;
  String? _marcaSeleccionadaId;

  // Archivo local seleccionado de la cámara o galería
  File? _imagenFileSeleccionada;

  bool _isLoadingData = true;
  bool _isSaving = false;

  static const darkForestGreen = Color(0xFF047857);
  static const softGreenBg = Color(0xFFECFDF5);

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
    _skuCtrl = TextEditingController(text: widget.producto?.sku ?? '');
    _precioCtrl = TextEditingController(text: widget.producto?.precio.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.producto?.stock.toString() ?? '0');
    _descripcionCtrl = TextEditingController(text: widget.producto?.descripcion ?? '');
    _imagenUrlCtrl = TextEditingController(text: widget.producto?.imagenUrl ?? '');

    _cargarRelaciones();
  }

  void _cargarRelaciones() async {
    final categoriasList = await _categoriaService.getCategorias();
    final marcasList = await _marcaService.getMarcas();

    setState(() {
      _categorias = categoriasList;
      _marcas = marcasList;

      if (widget.producto != null) {
        _categoriaSeleccionadaId = widget.producto!.categoriaId;
        _marcaSeleccionadaId = widget.producto!.marcaId;
      } else {
        if (_categorias.isNotEmpty) _categoriaSeleccionadaId = _categorias.first.id;
        if (_marcas.isNotEmpty) _marcaSeleccionadaId = _marcas.first.id;
      }

      _isLoadingData = false;
    });
  }

  // Selecciona la foto localmente sin hacer peticiones a la API aún
  Future<void> _seleccionarImagenLocal(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (pickedFile == null) return;

      setState(() {
        _imagenFileSeleccionada = File(pickedFile.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al acceder a la imagen'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Imagen del Producto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: darkForestGreen),
              title: const Text('Galería de Fotos'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagenLocal(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: darkForestGreen),
              title: const Text('Tomar Foto con Cámara'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagenLocal(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionadaId == null || _marcaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes registrar al menos una Categoría y una Marca primero.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final nuevoProducto = Producto(
      id: widget.producto?.id,
      nombre: _nombreCtrl.text.trim(),
      sku: _skuCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text),
      stock: int.parse(_stockCtrl.text),
      descripcion: _descripcionCtrl.text.trim(),
      imagenUrl: _imagenUrlCtrl.text.trim(),
      categoria: _categoriaSeleccionadaId,
      marca: _marcaSeleccionadaId,
    );

    // Se envía el producto + la imagen seleccionada en una sola petición HTTP
    bool exito;
    if (widget.producto == null) {
      exito = await _productoService.createProducto(
        nuevoProducto,
        imagenFile: _imagenFileSeleccionada,
      );
    } else {
      exito = await _productoService.updateProducto(
        widget.producto!.id!,
        nuevoProducto,
        imagenFile: _imagenFileSeleccionada,
      );
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.producto == null ? 'Producto creado con éxito' : 'Producto actualizado con éxito'),
          backgroundColor: darkForestGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el producto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _skuCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _descripcionCtrl.dispose();
    _imagenUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.producto == null ? 'Nuevo Producto' : 'Editar Producto',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: darkForestGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.black54),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vista previa dinámica: Local (File) -> Remota (Network) -> Icono por defecto
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: softGreenBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: darkForestGreen.withOpacity(0.3), width: 1.5),
                    ),
                    child: _imagenFileSeleccionada != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        _imagenFileSeleccionada!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : (_imagenUrlCtrl.text.trim().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        _imagenUrlCtrl.text.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
                      ),
                    )
                        : const Icon(Icons.add_a_photo_outlined, color: darkForestGreen, size: 36)),
                  ),
                ),
                const SizedBox(height: 10),

                // Botón para seleccionar o cambiar foto
                Center(
                  child: TextButton.icon(
                    onPressed: _mostrarOpcionesImagen,
                    icon: const Icon(Icons.camera_alt_outlined, color: darkForestGreen),
                    label: Text(
                      (_imagenFileSeleccionada != null || _imagenUrlCtrl.text.isNotEmpty)
                          ? 'Cambiar Imagen'
                          : 'Seleccionar Imagen',
                      style: const TextStyle(color: darkForestGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre del Producto
                _buildTextField(
                  controller: _nombreCtrl,
                  label: 'Nombre del Producto *',
                  icon: Icons.inventory_2_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 14),

                // Código SKU
                _buildTextField(
                  controller: _skuCtrl,
                  label: 'Código SKU *',
                  icon: Icons.qr_code_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'El SKU es obligatorio' : null,
                ),
                const SizedBox(height: 14),

                // Precio y Stock
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _precioCtrl,
                        label: 'Precio (\$)*',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Inválido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _stockCtrl,
                        label: 'Stock *',
                        icon: Icons.format_list_numbered_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Inválido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dropdown Categoría
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionadaId,
                  decoration: _buildInputDecoration('Categoría *', Icons.category_outlined),
                  items: _categorias.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.nombre));
                  }).toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionadaId = val),
                  validator: (v) => v == null ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 14),

                // Dropdown Marca
                DropdownButtonFormField<String>(
                  value: _marcaSeleccionadaId,
                  decoration: _buildInputDecoration('Marca *', Icons.branding_watermark_outlined),
                  items: _marcas.map((m) {
                    return DropdownMenuItem(value: m.id, child: Text(m.nombre));
                  }).toList(),
                  onChanged: (val) => setState(() => _marcaSeleccionadaId = val),
                  validator: (v) => v == null ? 'Selecciona una marca' : null,
                ),
                const SizedBox(height: 14),

                // Descripción
                _buildTextField(
                  controller: _descripcionCtrl,
                  label: 'Descripción (Opcional)',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Botón Guardar
                ElevatedButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: darkForestGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: darkForestGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    widget.producto == null ? 'Guardar Producto' : 'Actualizar Producto',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w500),
      decoration: _buildInputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: darkForestGreen),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkForestGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}