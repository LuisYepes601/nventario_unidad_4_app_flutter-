import 'dart:async';
import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentHeroIndex = 0;
  Timer? _heroTimer;

  // Paleta de colores Executive Forest Green & Slate
  static const darkForestGreen = Color(0xFF047857);
  static const deepForest = Color(0xFF065F46);
  static const softGreenBg = Color(0xFFECFDF5);
  static const slateDark = Color(0xFF0F172A);
  static const slateMuted = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);
  static const accentMint = Color(0xFF6EE7B7);

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _cargarCategorias() {
    setState(() {
      _futureCategorias = _service.getCategorias();
    });
  }

  void _iniciarAutoPlayHero(int totalItems) {
    _heroTimer?.cancel();
    if (totalItems <= 1) return;

    _heroTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentHeroIndex + 1) % totalItems;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Mapea dinámicamente una imagen temática de alta calidad desde Unsplash
  String _obtenerImagenContextual(String nombre) {
    final nameLower = nombre.toLowerCase();
    if (nameLower.contains('cereal')) {
      return 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=800&q=80';
    } else if (nameLower.contains('lacteo') || nameLower.contains('leche') || nameLower.contains('queso')) {
      return 'https://images.unsplash.com/photo-1528750997573-59b89d66f4f7?w=800&q=80';
    } else if (nameLower.contains('bebida') || nameLower.contains('jugo') || nameLower.contains('gaseosa')) {
      return 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80';
    } else if (nameLower.contains('tecnologia') || nameLower.contains('electro') || nameLower.contains('celular')) {
      return 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80';
    } else if (nameLower.contains('limpieza') || nameLower.contains('hogar')) {
      return 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800&q=80';
    } else if (nameLower.contains('fruta') || nameLower.contains('verdura') || nameLower.contains('fresco')) {
      return 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800&q=80';
    } else if (nameLower.contains('snack') || nameLower.contains('dulce') || nameLower.contains('galleta')) {
      return 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=800&q=80';
    }
    // Imagen predeterminada para el inventario
    return 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&q=80';
  }

  // Diálogo para Crear o Editar una Categoría
  void _mostrarFormularioDialog({Categoria? categoria}) {
    final nombreController = TextEditingController(text: categoria?.nombre ?? '');
    final descripcionController = TextEditingController(text: categoria?.descripcion ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            categoria == null ? 'Nueva Categoría' : 'Editar Categoría',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: slateDark),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: _buildInputDecoration('Nombre de Categoría *', Icons.category_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descripcionController,
                  decoration: _buildInputDecoration('Descripción (Opcional)', Icons.description_outlined),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: slateMuted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkForestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final nuevaCat = Categoria(
                  id: categoria?.id ?? '',
                  nombre: nombreController.text.trim(),
                  descripcion: descripcionController.text.trim(),
                );

                bool exito;
                if (categoria == null) {
                  exito = await _service.createCategoria(nuevaCat);
                } else {
                  exito = await _service.updateCategoria(categoria.id, nuevaCat);
                }

                if (mounted) {
                  Navigator.pop(context);
                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(categoria == null ? 'Categoría creada' : 'Categoría actualizada'),
                        backgroundColor: darkForestGreen,
                      ),
                    );
                    _cargarCategorias();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al guardar la categoría'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text(categoria == null ? 'Guardar' : 'Actualizar', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Confirmar y eliminar categoría
  void _eliminarCategoria(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar categoría?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: slateDark)),
        content: const Text('Esta acción eliminará el registro de forma permanente.', style: TextStyle(color: slateMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: slateMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ok = await _service.deleteCategoria(id);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría eliminada'), backgroundColor: darkForestGreen),
          );
          _cargarCategorias();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar categoría'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Gestión de Categorías',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _cargarCategorias,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<Categoria>>(
        future: _futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: darkForestGreen, strokeWidth: 2.5));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('Error al cargar datos', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          final categorias = snapshot.data ?? [];
          if (categorias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: softGreenBg, shape: BoxShape.circle),
                    child: const Icon(Icons.category_outlined, size: 48, color: darkForestGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin categorías registradas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: slateDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Presiona el botón "+" para agregar una',
                    style: TextStyle(color: slateMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final heroItems = categorias.take(5).toList();
          _iniciarAutoPlayHero(heroItems.length);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- SECCIÓN HERO CARRUSEL ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categorías Destacadas',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: slateDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: softGreenBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: darkForestGreen.withOpacity(0.2)),
                              ),
                              child: Text(
                                '${categorias.length} Registradas',
                                style: const TextStyle(
                                  color: darkForestGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Carrusel con imágenes de Internet
                      SizedBox(
                        height: 165,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: heroItems.length,
                          onPageChanged: (index) {
                            setState(() => _currentHeroIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return _buildHeroCard(heroItems[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Dots Indicator Verde
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(heroItems.length, (index) {
                          final bool isSelected = _currentHeroIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isSelected ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? darkForestGreen : Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Todas las Categorías',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: slateDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // --- LISTADO DE CATEGORÍAS ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCategoriaCard(categorias[index]),
                    childCount: categorias.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 85)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioDialog(),
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nueva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  // Tarjeta Hero con Imagen HD de Internet + Gradient Overlay
  Widget _buildHeroCard(Categoria cat) {
    final String imageUrl = _obtenerImagenContextual(cat.nombre);

    return GestureDetector(
      onTap: () => _mostrarFormularioDialog(categoria: cat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de Fondo de Internet
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: deepForest,
                  child: const Center(
                    child: Icon(Icons.category_outlined, color: Colors.white54, size: 40),
                  ),
                ),
              ),

              // Degradado Oscuro
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // Elementos visuales superiores
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.category_rounded, color: accentMint, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: darkForestGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Categoría',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Texto e información inferior
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.descripcion.isNotEmpty ? cat.descripcion : 'Sin descripción registrada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tarjeta de Lista Limpia
  Widget _buildCategoriaCard(Categoria cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: softGreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.category_outlined, color: darkForestGreen, size: 24),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: slateDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cat.descripcion.isNotEmpty ? cat.descripcion : 'Sin descripción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: slateMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18),
                  onPressed: () => _mostrarFormularioDialog(categoria: cat),
                  tooltip: 'Editar',
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => _eliminarCategoria(cat.id),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: slateMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: darkForestGreen, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkForestGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}