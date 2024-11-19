class Book {
  final String? title;
  final String? author;
  final List<String>? genres;
  final String? description;
  final String? isbn;
  final String? borrowLink;
  final String? format;
  final bool? isAvailableForBorrow;

  Book({
    this.title,
    this.author,
    this.genres,
    this.description,
    this.isbn,
    this.borrowLink,
    this.format,
    this.isAvailableForBorrow,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['Title'] ?? '',
      author: json['Author'] ?? '',
      genres:
          (json['Genres'] as String).split(',').map((s) => s.trim()).toList(),
      description: json['Description'] ?? '',
      isbn: json['ISBN'] ?? '',
      borrowLink: json['BorrowLink'] ?? '',
      format: json['Format'] ?? '',
      isAvailableForBorrow: json['IsAvailableForBorrow'] == 1,
    );
  }
}
