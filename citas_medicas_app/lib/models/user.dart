import 'dart:convert';

class User {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String? profileImagePath; // ruta local de la foto

  User({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'password': password,
        'fullName': fullName,
        'email': email,
        'profileImagePath': profileImagePath,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        username: map['username'],
        password: map['password'],
        fullName: map['fullName'],
        email: map['email'],
        profileImagePath: map['profileImagePath'],
      );

  String toJson() => jsonEncode(toMap());
  factory User.fromJson(String json) => User.fromMap(jsonDecode(json));
}
