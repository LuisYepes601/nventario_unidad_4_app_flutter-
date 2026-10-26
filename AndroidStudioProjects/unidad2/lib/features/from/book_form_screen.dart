import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/database/book_model.dart';
import '../../core/utils/notification_helper.dart';
import '../../core/utils/validators.dart';
import '../export/csv_exporter.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();

  List<Book> _books = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await AppDatabase.instance.getBooks();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final newBook = Book(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      year: int.parse(_yearController.text.trim()),
    );

    // Guardar en la base de datos local
    await AppDatabase.instance.insertBook(newBook);

    // Disparar la notificación local
    await NotificationHelper.showBookRegisteredNotification(newBook.title);

    // Limpiar campos
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    _yearController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Libro guardado con éxito!')),
      );
    }

    _loadBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Libros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: () async {
              if (_books.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay libros para exportar')),
                );
                return;
              }
              await CsvExporter.exportAndShareBooks();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => Validators.validateNotEmpty(v, 'Título'),
                  ),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(labelText: 'Autor'),
                    validator: (v) => Validators.validateNotEmpty(v, 'Autor'),
                  ),
                  TextFormField(
                    controller: _isbnController,
                    decoration: const InputDecoration(labelText: 'ISBN'),
                    validator: Validators.validateIsbn,
                  ),
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: 'Año'),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateYear,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _saveBook,
                    icon: const Icon(Icons.save),
                    label: const Text('Registrar Libro'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Libros Registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _books.isEmpty
                  ? const Center(child: Text('No hay registros.'))
                  : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(book.title),
                    subtitle: Text('${book.author} • ${book.year}'),
                    trailing: Text('ISBN: ${book.isbn}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}