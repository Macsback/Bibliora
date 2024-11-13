class User {
  final int id;
  final String email;
  final String username;

  User({
    required this.id,
    required this.email,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['UserID'], email: json['Email'], username: json['Username']);
  }
}
