class Book {
  final String? title;
  final String? author;
  final List<String>? genres;
  final String? description;
  final String? isbn;
  final String? borrowLink;
  final String? format;
  final String? publishYear;
  final String? coverImageUrl;

  Book({
    this.title,
    this.author,
    this.genres,
    this.description,
    this.isbn,
    this.borrowLink,
    this.format,
    this.coverImageUrl,
    this.publishYear,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    String? coverImageUrl = json['cover_image_url'];

    coverImageUrl = coverImageUrl?.replaceFirst("http://", "https://");

    return Book(
      title: json['title'] ?? 'Unknown',
      author: json['author'] ?? 'Unknown',
      genres: (json['genres'] != null && json['genres'] is String)
          ? (json['genres'] as String).split(',').map((s) => s.trim()).toList()
          : [],
      description: json['description'] ?? 'Unknown',
      isbn: json['isbn'] ?? 'Unknown',
      borrowLink: json['borrowlink'] ?? 'Unknown',
      coverImageUrl: coverImageUrl,
      publishYear: json['publish_year']?.toString() ?? 'Unknown',
    );
  }
}
