import 'package:flutter/material.dart';
import 'user_provider.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String get userName => _currentUser?.name ?? '';
  String get userEmail => _currentUser?.email ?? '';

  // Simulamos inyección de UserProvider
  late UserProvider _userProvider;

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (email.isEmpty || password.isEmpty) {
        return false;
      }

      final user = _userProvider.validateCredentials(email, password);
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Registro
  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return false;
      }

      if (password != confirmPassword) {
        return false;
      }

      if (password.length < 4) {
        return false;
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        password: password,
        phone: '',
        birthDate: '',
        bloodType: 'O+',
      );

      return _userProvider.createUser(newUser);
    } catch (e) {
      return false;
    }
  }

  // Actualizar perfil
  bool updateProfile({
    required String name,
    required String phone,
    required String birthDate,
    required String bloodType,
    required String emergencyContact,
    required String emergencyPhone,
  }) {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      birthDate: birthDate,
      bloodType: bloodType,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
    );

    final success = _userProvider.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
    return success;
  }

  // Cambiar contraseña
  bool changePassword(String oldPassword, String newPassword, String confirmPassword) {
    if (_currentUser == null) return false;
    if (_currentUser!.password != oldPassword) return false;
    if (newPassword != confirmPassword) return false;
    if (newPassword.length < 4) return false;

    final updatedUser = _currentUser!.copyWith(password: newPassword);
    final success = _userProvider.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
    return success;
  }

  // Cierre de sesión
  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  // Eliminar cuenta
  bool deleteAccount(String password) {
    if (_currentUser == null) return false;
    if (_currentUser!.password != password) return false;

    final success = _userProvider.deleteUser(_currentUser!.id);
    if (success) {
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    }
    return success;
  }
}
