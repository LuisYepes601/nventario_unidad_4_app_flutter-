class Book {
  final int? id;
  final String title;
  final String author;
  final String isbn;
  final int year;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'year': year,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
      isbn: map['isbn'] as String,
      year: map['year'] as int,
    );
  }
}