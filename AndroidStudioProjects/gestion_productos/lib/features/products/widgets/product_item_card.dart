import 'package:flutter/material.dart';
import '../../products/data/product_model.dart';

class ProductItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.stock <= product.stockMinimo;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: product.imagenPrincipal != null && product.imagenPrincipal!.isNotEmpty
              ? Image.network(
            product.imagenPrincipal!,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40),
          )
              : const Icon(Icons.inventory_2, size: 40),
        ),
        title: Text(
          product.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product.sku} | Cat: ${product.categoria?.nombre ?? 'Sin cat.'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Precio: \$${product.precioVenta.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Editar')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Eliminar')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}