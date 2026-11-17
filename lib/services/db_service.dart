import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class DB {
  static late Box _users, _wish;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    _users = await Hive.openBox('users');
    _wish = await Hive.openBox('wishlist');
    _prefs = await SharedPreferences.getInstance();
  }

  static String _hash(String p) => sha256.convert(utf8.encode(p)).toString();
  static String _key(int id, String u) => '$u:$id';

  // ---------- SESSION (SharedPreferences) ----------
  static String? get currentUser => _prefs.getString('user');
  static Future<void> setSession(String u) => _prefs.setString('user', u);
  static Future<void> clearSession() => _prefs.remove('user');

  // ---------- USER (Hive) ----------
  static Future<bool> register(String u, String p) async {
    if (_users.containsKey(u)) return false;
    await _users.put(u, User(username: u, passwordHash: _hash(p)).toJson());
    return true;
  }

  static Future<bool> login(String u, String p) async {
    final m = _users.get(u);
    if (m == null) return false;
    final user = User.fromJson(Map<String, dynamic>.from(m as Map));
    return user.passwordHash == _hash(p);
  }

  // ---------- WISHLIST (Hive) ----------
  static Future<bool> isWishlisted(int id, String u) async =>
      _wish.containsKey(_key(id, u));

  static Future<void> addWishlist(Product p, String u) =>
      _wish.put(_key(p.id, u), p.toMap(u));

  static Future<void> removeWishlist(int id, String u) =>
      _wish.delete(_key(id, u));

  static Future<List<Product>> wishlist(String u) async => _wish.values
      .map((e) => Map<String, dynamic>.from(e as Map))
      .where((m) => m['username'] == u)
      .map((m) => Product.fromMap(m))
      .toList();
}