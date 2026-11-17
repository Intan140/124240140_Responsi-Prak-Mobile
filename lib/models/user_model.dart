class User {
  final String username;
  final String passwordHash;

  User({required this.username, required this.passwordHash});

  factory User.fromJson(Map<String, dynamic> j) =>
      User(username: j['username'], passwordHash: j['passwordHash']);

  Map<String, dynamic> toJson() =>
      {'username': username, 'passwordHash': passwordHash};
}