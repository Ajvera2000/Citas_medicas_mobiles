import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'logged_in';
  static const _keyUser = 'user';
  static const _keyUsers = 'users'; // Lista de usuarios registrados

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_keyUsers) ?? [];

    for (var u in users) {
      final parts = u.split('|'); // Formato: username:password:profileImage
      if (parts[0] == username && parts[1] == password) {
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString(_keyUser, u);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String username, String password, {String? profileImage}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_keyUsers) ?? [];

    if (users.any((u) => u.split('|')[0] == username)) return false;

    // Guardar como: username|password|profileImage
    users.add('$username|$password|${profileImage ?? ""}');
    await prefs.setStringList(_keyUsers, users);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUser);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<Map<String, String>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_keyUser);
    if (userString == null) return null;
    final parts = userString.split('|');
    return {
      'username': parts[0],
      'password': parts[1],
      'profileImage': parts.length > 2 ? parts[2] : '',
    };
  }
}
