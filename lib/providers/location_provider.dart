import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  double _userLatitude = 0;
  double _userLongitude = 0;
  bool _isLoading = false;
  String? _errorMessage;

  double get userLatitude => _userLatitude;
  double get userLongitude => _userLongitude;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LocationProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await getUserLocation();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage =
          'El servicio de ubicación está deshabilitado. Por favor, habilítalo.';
      notifyListeners();
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Permiso de ubicación denegado';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage =
          'Permiso de ubicación denegado permanentemente. Habilítalo en configuración.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> getUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 1. Intentar obtener la última conocida (es súper rápido)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        notifyListeners(); // Muestra algo en el mapa rápido
      }

      // 2. Usando ubicación real del dispositivo con límite de tiempo
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10), // Evita carga infinita
        ),
      );
      _userLatitude = position.latitude;
      _userLongitude = position.longitude;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: $e';
      // Si todo falla, ponemos una ubicación de emergencia para no romper el mapa
      if (_userLatitude == 0 && _userLongitude == 0) {
        _userLatitude = -33.8688;
        _userLongitude = -51.5288;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> watchUserLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Actualizar cada 100 metros
      ),
    ).listen((Position position) {
      _userLatitude = position.latitude;
      _userLongitude = position.longitude;
      notifyListeners();
    });
  }
}
