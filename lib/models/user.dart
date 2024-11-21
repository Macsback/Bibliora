class User {
  final int userId;
  final String username;
  final String email;
  final String memberSince;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.memberSince,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserID'],
      username: json['Username'],
      email: json['Email'],
      memberSince: json['MemberSince'],
    );
  }
}
