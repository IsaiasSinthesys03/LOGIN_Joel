import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../core/models/user.dart'; // RUTA CORREGIDA

enum LoginStatus { init, loading, failure, success }

class AuthProvider with ChangeNotifier {
  final _repo = UserRepository();
  AppUser? _current;
  LoginStatus _status = LoginStatus.init;
  String? _lastError;

  AppUser? get current => _current;
  LoginStatus get status => _status;
  String? get lastError => _lastError;

  Future<void> loadSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_email');
    if (email != null) {
      _current = await _repo.getByEmail(email);
      notifyListeners();
    }
  }

  String _hash(String plain) => sha256.convert(utf8.encode(plain)).toString();

  Future<String?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Unicidad por email como identificador principal
      final exists = await _repo.getByEmail(email);
      if (exists != null) return 'El correo ya está registrado';
      final user = AppUser(
        fullName: fullName,
        username: username,
        email: email,
        passwordHash: _hash(password),
      );
      await _repo.create(user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    _status = LoginStatus.loading;
    _lastError = null;
    notifyListeners();
    try {
      final user = await _repo.getByEmail(email);
      if (user == null) {
        _status = LoginStatus.failure;
        _lastError = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        notifyListeners();
        return _lastError;
      }
      if (user.passwordHash != _hash(password)) {
        _status = LoginStatus.failure;
        _lastError = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        notifyListeners();
        return _lastError;
      }
      _current = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_email', user.email);
      _status = LoginStatus.success;
      notifyListeners();
      return null;
    } catch (e) {
      _status = LoginStatus.failure;
      _lastError = 'Error interno del sistema. No se pudo verificar la base de datos.';
      notifyListeners();
      return _lastError;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_email');
    _current = null;
    _status = LoginStatus.init;
    _lastError = null;
    notifyListeners();
  }

  void clearError() {
    if (_status == LoginStatus.failure) {
      _status = LoginStatus.init;
      _lastError = null;
      notifyListeners();
    }
  }
}