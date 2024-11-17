class BookClub {
  final int id;
  final String name;
  final String description;

  BookClub({
    required this.id,
    required this.name,
    required this.description,
  });

  factory BookClub.fromJson(Map<String, dynamic> json) {
    return BookClub(
      id: json['BookClubID'],
      name: json['Name'],
      description: json['Description'],
    );
  }
}
