import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../config/app_config.dart';

class PlacesService {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const _radiusMeters = 3000;

  static Future<List<Location>> fetchNearby({
    required double lat,
    required double lon,
    required String type,
  }) async {
    if (type == 'all') {
      final results = await Future.wait([
        _fetchByApiType(lat, lon, 'pharmacy', appType: 'pharmacy'),
        _fetchByApiType(lat, lon, 'hospital', appType: 'hospital'),
        _fetchByApiType(lat, lon, 'doctor', appType: 'clinic'),
      ]);
      final combined = results.expand((list) => list).toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));
      return combined;
    }

    final apiType = type == 'clinic' ? 'doctor' : type;
    return _fetchByApiType(lat, lon, apiType, appType: type);
  }

  static Future<List<Location>> _fetchByApiType(
    double lat,
    double lon,
    String apiType, {
    required String appType,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?location=$lat,$lon&radius=$_radiusMeters&type=$apiType&key=${AppConfig.googleMapsApiKey}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String;
    if (status == 'ZERO_RESULTS') return [];
    if (status != 'OK') throw Exception('Places API error: $status');

    final results = data['results'] as List<dynamic>;
    return results.map((place) {
      final geo = place['geometry']['location'];
      final placeLat = (geo['lat'] as num).toDouble();
      final placeLon = (geo['lng'] as num).toDouble();

      String hours = '';
      final openingHours = place['opening_hours'];
      if (openingHours != null) {
        hours = openingHours['open_now'] == true ? 'Abierto ahora' : 'Cerrado';
      }

      return Location(
        latitude: placeLat,
        longitude: placeLon,
        name: place['name'] as String? ?? 'Sin nombre',
        type: appType,
        address: place['vicinity'] as String? ?? '',
        phone: '',
        hours: hours,
        distance: _haversine(lat, lon, placeLat, placeLon),
      );
    }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
