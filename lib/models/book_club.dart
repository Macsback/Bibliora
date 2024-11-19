class BookClub {
  final String name;
  final String description;

  BookClub({required this.name, required this.description});

  factory BookClub.fromJson(Map<String, dynamic> json) {
    return BookClub(
      name: json['Name'] as String? ?? 'Untitled Club',
      description:
          json['Description'] as String? ?? 'No description available.',
    );
  }
}
