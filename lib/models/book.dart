class Book {
  final String title;
  final String author;
  final String description;
  final String borrowLink;
  final String format;
  final String genres;
  final String isbn;
  final bool isAvailableForBorrow;
  final String? digitalLink;
  final String? digitalVersion;

  Book({
    required this.title,
    required this.author,
    required this.description,
    required this.borrowLink,
    required this.format,
    required this.genres,
    required this.isbn,
    required this.isAvailableForBorrow,
    this.digitalLink,
    this.digitalVersion,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['Title'],
      author: json['Author'],
      description: json['Description'],
      borrowLink: json['BorrowLink'],
      format: json['Format'],
      genres: json['Genres'],
      isbn: json['ISBN'],
      isAvailableForBorrow: json['IsAvailableForBorrow'] == 1,
      digitalLink: json['DigitalLink'],
      digitalVersion: json['DigitalVersion'],
    );
  }
}
