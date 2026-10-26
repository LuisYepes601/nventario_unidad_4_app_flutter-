import 'dart:async';
import 'package:flutter/material.dart';
import '../models/marca.dart';
import '../services/marca_service.dart';

class MarcasScreen extends StatefulWidget {
  const MarcasScreen({super.key});

  @override
  State<MarcasScreen> createState() => _MarcasScreenState();
}

class _MarcasScreenState extends State<MarcasScreen> {
  final MarcaService _service = MarcaService();
  late Future<List<Marca>> _futureMarcas;

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
    _cargarMarcas();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _cargarMarcas() {
    setState(() {
      _futureMarcas = _service.getMarcas();
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

  // Mapea imágenes contextuales empresariales según el nombre/país
  String _obtenerImagenContextual(String nombre, String pais) {
    final nameLower = nombre.toLowerCase();
    final paisLower = pais.toLowerCase();

    if (nameLower.contains('tech') || nameLower.contains('apple') || nameLower.contains('samsung') || nameLower.contains('sony')) {
      return 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80';
    } else if (nameLower.contains('nike') || nameLower.contains('adidas') || nameLower.contains('puma') || nameLower.contains('moda')) {
      return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80';
    } else if (nameLower.contains('food') || nameLower.contains('nestle') || nameLower.contains('coca')) {
      return 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=800&q=80';
    } else if (paisLower.contains('colombia') || paisLower.contains('local')) {
      return 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=800&q=80';
    }
    // Imagen corporativa/ejecutiva por defecto
    return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80';
  }

  // Diálogo para Crear o Editar una Marca
  void _mostrarFormularioDialog({Marca? marca}) {
    final nombreController = TextEditingController(text: marca?.nombre ?? '');
    final paisController = TextEditingController(text: marca?.paisOrigen ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            marca == null ? 'Nueva Marca' : 'Editar Marca',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: slateDark),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: _buildInputDecoration('Nombre de la Marca *', Icons.branding_watermark_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: paisController,
                  decoration: _buildInputDecoration('País de Origen (Opcional)', Icons.public_outlined),
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

                final nuevaMarca = Marca(
                  id: marca?.id ?? '',
                  nombre: nombreController.text.trim(),
                  paisOrigen: paisController.text.trim().isEmpty
                      ? 'Desconocido'
                      : paisController.text.trim(),
                );

                bool exito;
                if (marca == null) {
                  exito = await _service.createMarca(nuevaMarca);
                } else {
                  exito = await _service.updateMarca(marca.id, nuevaMarca);
                }

                if (mounted) {
                  Navigator.pop(context);
                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(marca == null ? 'Marca creada' : 'Marca actualizada'),
                        backgroundColor: darkForestGreen,
                      ),
                    );
                    _cargarMarcas();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al guardar la marca'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text(marca == null ? 'Guardar' : 'Actualizar', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Eliminar Marca
  void _eliminarMarca(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar marca?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: slateDark)),
        content: const Text('Esta acción eliminará la marca del catálogo permanentemente.', style: TextStyle(color: slateMuted)),
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
      final ok = await _service.deleteMarca(id);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marca eliminada con éxito'), backgroundColor: darkForestGreen),
          );
          _cargarMarcas();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la marca'),
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
          'Gestión de Marcas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _cargarMarcas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<Marca>>(
        future: _futureMarcas,
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

          final marcas = snapshot.data ?? [];
          if (marcas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: softGreenBg, shape: BoxShape.circle),
                    child: const Icon(Icons.branding_watermark_outlined, size: 48, color: darkForestGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin marcas registradas',
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

          final heroItems = marcas.take(5).toList();
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
                              'Marcas Aliadas',
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
                                '${marcas.length} Activas',
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

                      // Carrusel Hero
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

                      // Dots Indicator
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
                          'Todas las Marcas',
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

              // --- LISTADO GENERAL DE MARCAS ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMarcaCard(marcas[index]),
                    childCount: marcas.length,
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

  // Tarjeta Hero con Imagen de Empresa/Marca + Gradient Overlay
  Widget _buildHeroCard(Marca marca) {
    final String imageUrl = _obtenerImagenContextual(marca.nombre, marca.paisOrigen);

    return GestureDetector(
      onTap: () => _mostrarFormularioDialog(marca: marca),
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
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: deepForest,
                  child: const Center(
                    child: Icon(Icons.branding_watermark_outlined, color: Colors.white54, size: 40),
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
                      child: const Icon(Icons.verified_rounded, color: accentMint, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: darkForestGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '📍 ${marca.paisOrigen}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Nombre de la marca e info inferior
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      marca.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Socio comercial verificado',
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
  Widget _buildMarcaCard(Marca marca) {
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
              child: const Icon(Icons.branding_watermark_outlined, color: darkForestGreen, size: 24),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marca.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: slateDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '📍 ${marca.paisOrigen}',
                      style: const TextStyle(color: slateMuted, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
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
                  onPressed: () => _mostrarFormularioDialog(marca: marca),
                  tooltip: 'Editar',
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => _eliminarMarca(marca.id),
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