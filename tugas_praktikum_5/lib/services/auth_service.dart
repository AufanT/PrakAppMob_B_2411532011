import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _kunciSesi = 'logged_in_user_id';

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  String _normalisasiEmail(String email) => email.trim().toLowerCase();

  Future<void> restoreSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt(_kunciSesi);
    if (userId == null) return;

    final AppUser? user = await DatabaseHelper.instance.getUserById(userId);
    if (user == null) {
      await prefs.remove(_kunciSesi);
      return;
    }
    _currentUser = user;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final String emailBersih = _normalisasiEmail(email);
    final AppUser? sudahAda =
        await DatabaseHelper.instance.getUserByEmail(emailBersih);
    if (sudahAda != null) {
      throw const AuthException('Email sudah terdaftar, silakan login');
    }

    final AppUser userBaru = AppUser(
      name: name.trim(),
      email: emailBersih,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );
    final int id = await DatabaseHelper.instance.insertUser(userBaru);
    return userBaru.copyWith(id: id);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final AppUser? user =
        await DatabaseHelper.instance.getUserByEmail(_normalisasiEmail(email));
    if (user == null || user.passwordHash != _hashPassword(password)) {
      throw const AuthException('Email atau password salah');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kunciSesi, user.id!);
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciSesi);
    _currentUser = null;
  }
}
