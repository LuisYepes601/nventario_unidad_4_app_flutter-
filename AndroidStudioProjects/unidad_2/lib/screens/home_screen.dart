import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/producto.dart';
import '../util/notification_helper.dart';
import '../util/sv_exporter.dart';
import '../util/page_transitions.dart';
import 'agregar_producto_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Producto> _productos = [];
  final _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final lista = await DatabaseHelper.instance.obtenerTodos();
    setState(() => _productos = lista);

    for (final p in lista.where((p) => p.cantidad <= 5)) {
      await NotificationHelper.notificarStockBajo(p.nombre, p.cantidad);
    }
  }

  Future<void> _filtrar() async {
    final texto = _filtroController.text.trim();
    if (texto.isEmpty) {
      _cargarProductos();
    } else {
      final lista = await DatabaseHelper.instance.filtrarPorCategoria(texto);
      setState(() => _productos = lista);
    }
  }

  Future<void> _eliminarConUndo(Producto p) async {
    final index = _productos.indexOf(p);
    setState(() => _productos.remove(p));
    await DatabaseHelper.instance.eliminar(p.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${p.nombre}" eliminado'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await DatabaseHelper.instance.insertar(p);
            setState(() => _productos.insert(index.clamp(0, _productos.length), p));
          },
        ),
      ),
    );
  }

  Future<void> _exportar() async {
    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos para exportar')),
      );
      return;
    }
    await CsvExporter.exportarYCompartir(_productos);
  }

  int get _stockBajoCount => _productos.where((p) => p.cantidad <= 5).length;
  double get _valorTotal =>
      _productos.fold(0.0, (sum, p) => sum + (p.precio * p.cantidad));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarProductos,
          color: const Color(0xFF1565C0),
          child: Column(
            children: [
              // ---- HEADER CON DEGRADADO ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'InventarioApp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gestiona tu inventario fácil',
                                style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (valor) {
                            if (valor == 'exportar') _exportar();
                            if (valor == 'acerca') {
                              showDialog(
                                context: context,
                                builder: (_) => const AlertDialog(
                                  title: Text('Acerca de'),
                                  content: Text(
                                      'InventarioApp\nActividad 2 - Flutter\nGestión de inventario con SQLite, alertas y exportación.'),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'exportar',
                                child: Text('Exportar a CSV')),
                            PopupMenuItem(
                                value: 'acerca', child: Text('Acerca de')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // ---- MINI ESTADÍSTICAS ----
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.inventory_outlined,
                            label: 'Productos',
                            value: '${_productos.length}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.warning_amber_rounded,
                            label: 'Stock bajo',
                            value: '$_stockBajoCount',
                            alerta: _stockBajoCount > 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.attach_money,
                            label: 'Valor total',
                            value: '\$${_valorTotal.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---- BUSCADOR ----
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: Colors.grey),
                      Expanded(
                        child: TextField(
                          controller: _filtroController,
                          decoration: const InputDecoration(
                            hintText: 'Filtrar por categoría',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => _filtrar(),
                        ),
                      ),
                      IconButton(
                          onPressed: _filtrar,
                          icon: const Icon(Icons.arrow_forward,
                              color: Color(0xFF1565C0))),
                    ],
                  ),
                ),
              ),

              // ---- LISTADO ----
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _productos.isEmpty
                      ? Center(
                    key: const ValueKey('vacio'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No hay productos registrados',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    key: const ValueKey('lista'),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _productos.length,
                    itemBuilder: (ctx, i) {
                      final p = _productos[i];
                      final stockBajo = p.cantidad <= 5;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 250 + i * 40),
                        curve: Curves.easeOut,
                        builder: (context, valor, child) => Opacity(
                          opacity: valor,
                          child: Transform.translate(
                            offset: Offset(0, (1 - valor) * 20),
                            child: child,
                          ),
                        ),
                        child: Dismissible(
                          key: ValueKey(p.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar producto'),
                                content: Text(
                                    '¿Deseas eliminar "${p.nombre}"?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Eliminar')),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (_) => _eliminarConUndo(p),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: stockBajo
                                    ? Colors.red.shade50
                                    : Colors.blue.shade50,
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: stockBajo
                                      ? Colors.red
                                      : const Color(0xFF1565C0),
                                ),
                              ),
                              title: Text(p.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${p.categoria} · \$${p.precio} · Stock: ${p.cantidad}\n${p.emailProveedor}',
                                style: TextStyle(
                                    color: stockBajo
                                        ? Colors.red
                                        : Colors.black87),
                              ),
                              isThreeLine: true,
                              trailing: stockBajo
                                  ? const Icon(Icons.warning_amber_rounded,
                                  color: Colors.red)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-agregar',
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        onPressed: () async {
          await Navigator.push(
            context,
            SlideUpRoute(page: const AgregarProductoScreen()),
          );
          _cargarProductos();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool alerta;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.alerta = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: alerta
            ? Border.all(color: Colors.amberAccent, width: 1.2)
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}