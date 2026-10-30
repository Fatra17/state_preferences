import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  // Getter untuk mengakses state
  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => List.unmodifiable(_favorites);

  // Constructor: otomatis panggil _loadUser saat provider dibuat
  UserProvider() {
    _loadUser();
  }

  // Memuat data dari SharedPreferences
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    final currentVisits = prefs.getInt('visit_count') ?? 0;
    final newVisits = currentVisits + 1;
    await prefs.setInt('visit_count', newVisits);

    _favorites = prefs.getStringList('favorites') ?? [];
    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
    _isDarkMode = isDarkMode;
    _visitCount = newVisits;
    _isLoading = false;

    notifyListeners(); // Beritahu UI untuk rebuild
  }

  // Update profil user
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Toggle tema (Dark/Light)
  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    _isDarkMode = value;
    notifyListeners();
  }

  // Tambah item favorit
  Future<void> addFavorite(String item) async {
    if (item.trim().isEmpty) return;
    _favorites.add(item.trim());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Hapus item favorit
  Future<void> removeFavorite(String item) async {
    _favorites.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);
    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }
}