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
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      memberSince: json['MemberSince'],
    );
  }
}
