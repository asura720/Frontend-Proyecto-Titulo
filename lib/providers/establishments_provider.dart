import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/places_service.dart';

class EstablishmentsProvider extends ChangeNotifier {
  List<Location> _establishments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Location> get establishments => _establishments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNearby(double lat, double lon, String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _establishments = await PlacesService.fetchNearby(
        lat: lat,
        lon: lon,
        type: type,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar establecimientos';
      _establishments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Location> get pharmacies =>
      _establishments.where((e) => e.type == 'pharmacy').toList();

  List<Location> get hospitals =>
      _establishments.where((e) => e.type == 'hospital').toList();

  List<Location> get clinics =>
      _establishments.where((e) => e.type == 'clinic').toList();
}
