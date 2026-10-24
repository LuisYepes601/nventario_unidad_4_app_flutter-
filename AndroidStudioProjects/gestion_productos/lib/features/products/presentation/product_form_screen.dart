import 'package:flutter/material.dart';
import '../../../features/categories/data/category_model.dart';
import '../../../features/categories/data/category_repository.dart';
import '../../products/data/product_model.dart';
import '../../products/data/product_repository.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Controladores de texto
  late TextEditingController _skuController;
  late TextEditingController _nombreController;
  late TextEditingController _precioCostoController;
  late TextEditingController _precioVentaController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinimoController;
  late TextEditingController _marcaController;
  late TextEditingController _imagenController;
  late TextEditingController _descripcionController;

  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _precioCostoController = TextEditingController(text: p != null ? p.precioCosto.toString() : '');
    _precioVentaController = TextEditingController(text: p != null ? p.precioVenta.toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '');
    _stockMinimoController = TextEditingController(text: p != null ? p.stockMinimo.toString() : '5');
    _marcaController = TextEditingController(text: p?.marca ?? '');
    _imagenController = TextEditingController(text: p?.imagenPrincipal ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');

    _selectedCategoryId = p?.categoria?.id;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar categorías: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nombreController.dispose();
    _precioCostoController.dispose();
    _precioVentaController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _marcaController.dispose();
    _imagenController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final productData = Product(
      id: widget.product?.id,
      sku: _skuController.text.trim(),
      nombre: _nombreController.text.trim(),
      precioCosto: double.parse(_precioCostoController.text),
      precioVenta: double.parse(_precioVentaController.text),
      stock: int.parse(_stockController.text),
      stockMinimo: int.parse(_stockMinimoController.text),
      marca: _marcaController.text.trim(),
      imagenPrincipal: _imagenController.text.trim(),
      descripcion: _descripcionController.text.trim(),
    );

    try {
      if (isEditing) {
        await _productRepository.updateProduct(
          widget.product!.id!,
          productData,
          _selectedCategoryId!,
        );
      } else {
        await _productRepository.createProduct(
          productData,
          _selectedCategoryId!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Producto actualizado correctamente' : 'Producto creado con éxito',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU (Código único)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'El SKU es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categories.any((c) => c.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.nombre),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCostoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio Costo',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _precioVentaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio Venta',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Inicial',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockMinimoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Mínimo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagenController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de Imagen Principal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(
                  isEditing ? 'Actualizar Producto' : 'Guardar Producto',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}