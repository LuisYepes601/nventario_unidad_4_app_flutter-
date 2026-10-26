import 'dart:async';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import 'producto_form_screen.dart';
import '../../categorias/screens/categorias_screen.dart';
import '../../marcas/screens/marcas_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futureProductos;

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

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _cargarProductos() {
    setState(() {
      _futureProductos = _service.getProductos();
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

  void _irAFormulario({Producto? producto}) async {
    final refrescar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(producto: producto),
      ),
    );

    if (refrescar == true) {
      _cargarProductos();
    }
  }

  void _eliminarProducto(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar producto?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Esta acción quitará el producto del inventario permanentemente.', style: TextStyle(color: slateMuted)),
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
      final ok = await _service.deleteProducto(id);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado con éxito'),
              backgroundColor: darkForestGreen,
            ),
          );
          _cargarProductos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el producto'), backgroundColor: Colors.redAccent),
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
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _cargarProductos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: darkForestGreen, strokeWidth: 2.5),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('Error al cargar inventario', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: softGreenBg, shape: BoxShape.circle),
                    child: const Icon(Icons.inventory_2_outlined, size: 48, color: darkForestGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin productos registrados',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: slateDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toca el botón "+ Nuevo" para comenzar',
                    style: TextStyle(color: slateMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final heroProductos = productos.where((p) => p.imagenUrl.isNotEmpty).toList();
          final heroItems = heroProductos.isNotEmpty ? heroProductos.take(5).toList() : productos.take(3).toList();

          _iniciarAutoPlayHero(heroItems.length);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- SECCIÓN HERO ---
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
                              'Destacados',
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
                                '${productos.length} items',
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

                      // Carrusel Minimalista
                      SizedBox(
                        height: 170,
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

                      // Indicador de Puntos (Dots)
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
                              color: isSelected ? darkForestGreen : Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Catálogo General',
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

              // --- LISTADO GENERAL DE PRODUCTOS ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductoCard(productos[index]),
                    childCount: productos.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 85)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _irAFormulario(),
        backgroundColor: darkForestGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  // Tarjeta Hero Minimalista
  Widget _buildHeroCard(Producto prod) {
    return GestureDetector(
      onTap: () => _irAFormulario(producto: prod),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              prod.imagenUrl.isNotEmpty
                  ? Image.network(
                prod.imagenUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildHeroPlaceholder(),
              )
                  : _buildHeroPlaceholder(),

              // Gradient Overlay Suave
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // Chip "Destacado"
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Destacado',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Información Inferior
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prod.categoriaNombre.toUpperCase(),
                            style: TextStyle(
                              color: Colors.greenAccent.shade100,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prod.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SKU: ${prod.sku}',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${prod.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: darkForestGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
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

  Widget _buildHeroPlaceholder() {
    return Container(
      color: const Color(0xFF0F291E),
      child: Center(
        child: Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacity(0.25), size: 48),
      ),
    );
  }

  // Tarjeta de Producto Limpia y Organizada
  Widget _buildProductoCard(Producto prod) {
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
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Imagen del Producto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: prod.imagenUrl.isNotEmpty
                  ? Image.network(
                prod.imagenUrl,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackImage(),
              )
                  : _buildFallbackImage(),
            ),
            const SizedBox(width: 12),

            // Contenido Principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Marca Pills
                  Row(
                    children: [
                      _buildTag(prod.categoriaNombre, const Color(0xFFF1F5F9), slateMuted),
                      const SizedBox(width: 4),
                      _buildTag(prod.marcaNombre, softGreenBg, darkForestGreen),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Nombre del Producto
                  Text(
                    prod.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: slateDark,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // SKU + Stock
                  Row(
                    children: [
                      Text(
                        'SKU: ${prod.sku}',
                        style: const TextStyle(color: slateMuted, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      _buildStockBadge(prod.stock),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Precio
                  Text(
                    '\$${prod.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: darkForestGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Botones de Acción (Editar / Eliminar)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18),
                  onPressed: () => _irAFormulario(producto: prod),
                  tooltip: 'Editar',
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => _eliminarProducto(prod.id!),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 68,
      height: 68,
      color: softGreenBg,
      child: const Icon(Icons.inventory_2_outlined, color: darkForestGreen, size: 28),
    );
  }

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStockBadge(int stock) {
    final bool hasStock = stock > 0;
    final Color badgeBg = hasStock ? softGreenBg : const Color(0xFFFEF2F2);
    final Color textColor = hasStock ? darkForestGreen : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Stock: $stock',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkForestGreen, deepForest],
              ),
            ),
            accountName: const Text(
              'Gestión de Inventario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text(
              'Panel Administrativo',
              style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.15),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 32),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: darkForestGreen),
            title: const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: true,
            selectedTileColor: softGreenBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: darkForestGreen),
            title: const Text('Categorías'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriasScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.branding_watermark_outlined, color: darkForestGreen),
            title: const Text('Marcas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MarcasScreen()));
            },
          ),
        ],
      ),
    );
  }
}