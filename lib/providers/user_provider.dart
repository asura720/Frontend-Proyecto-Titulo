import 'package:flutter/material.dart';

class User {
  final String id;
  String name;
  String email;
  String password;
  String phone;
  String birthDate;
  String bloodType;
  String emergencyContact;
  String emergencyPhone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
    this.birthDate = '',
    this.bloodType = 'O+',
    this.emergencyContact = '',
    this.emergencyPhone = '',
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    };
  }

  // Crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'] ?? '',
      birthDate: json['birthDate'] ?? '',
      bloodType: json['bloodType'] ?? 'O+',
      emergencyContact: json['emergencyContact'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
    );
  }

  // Clonar con cambios
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? birthDate,
    String? bloodType,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }
}

class UserProvider extends ChangeNotifier {
  final List<User> _users = [
    User(
      id: '1',
      name: 'María Rodríguez',
      email: 'maria@example.com',
      password: '1234',
      phone: '+56 9 8765 4321',
      birthDate: '15 de Marzo, 1985',
      bloodType: 'O+',
      emergencyContact: 'Ana Rodríguez (Hermana)',
      emergencyPhone: '+56 9 1234 5678',
    ),
    User(
      id: '2',
      name: 'Juan García López',
      email: 'juan@example.com',
      password: '1234',
      phone: '+56 9 8765 4322',
      birthDate: '20 de Junio, 1978',
      bloodType: 'A+',
      emergencyContact: 'Carlos García (Hijo)',
      emergencyPhone: '+56 9 1234 5679',
    ),
  ];

  // Obtener todos los usuarios
  List<User> get users => _users;

  // Buscar usuario por email
  User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Crear usuario
  bool createUser(User user) {
    if (getUserByEmail(user.email) != null) {
      return false; // Email ya existe
    }
    _users.add(user);
    notifyListeners();
    return true;
  }

  // Actualizar usuario
  bool updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Eliminar usuario
  bool deleteUser(String userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Verificar credenciales
  User? validateCredentials(String email, String password) {
    final user = getUserByEmail(email);
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }
}
