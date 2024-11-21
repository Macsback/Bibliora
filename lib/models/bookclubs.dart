class BookClub {
  final int? bookClubId;
  final String? bookClubName;
  final String? description;

  BookClub({
    this.bookClubId,
    this.bookClubName,
    this.description,
  });

  factory BookClub.fromJson(Map<String, dynamic> json) {
    return BookClub(
      bookClubId: json['BookClubID'],
      bookClubName: json['Name'] ?? json['BookClubName'],
      description: json['Description'],
    );
  }
}