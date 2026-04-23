import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/location_provider.dart';
import '../providers/establishments_provider.dart';
import '../models/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  String _filterType = 'all';
  Set<Marker> _markers = {};

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchAndUpdateMarkers();
  }

  Future<void> _fetchAndUpdateMarkers() async {
    final loc = context.read<LocationProvider>();
    final est = context.read<EstablishmentsProvider>();
    await est.fetchNearby(loc.userLatitude, loc.userLongitude, _filterType);
    if (mounted) _updateMarkers();
  }

  void _updateMarkers() {
    final loc = context.read<LocationProvider>();
    final est = context.read<EstablishmentsProvider>();

    Set<Marker> newMarkers = {};

    final userLat = loc.userLatitude;
    final userLon = loc.userLongitude;

    if (userLat != 0 && userLon != 0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(userLat, userLon),
          infoWindow: const InfoWindow(
            title: 'Tu Ubicación',
            snippet: 'Aquí estás en este momento',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var establishment in est.establishments) {
      BitmapDescriptor markerColor;
      String typeLabel;

      if (establishment.type == 'pharmacy') {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        typeLabel = 'Farmacia';
      } else if (establishment.type == 'hospital') {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        typeLabel = 'Hospital';
      } else {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        typeLabel = 'Clínica';
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId('${establishment.type}_${establishment.name}'),
          position: LatLng(establishment.latitude, establishment.longitude),
          infoWindow: InfoWindow(
            title: establishment.name,
            snippet: '$typeLabel · ${establishment.distance.toStringAsFixed(1)} km'
                '${establishment.hours.isNotEmpty ? ' · ${establishment.hours}' : ''}',
          ),
          icon: markerColor,
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _filterEstablishments(String type) {
    setState(() {
      _filterType = type;
    });
    _fetchAndUpdateMarkers();
  }

  List<Location> _filteredEstablishments(EstablishmentsProvider est) {
    switch (_filterType) {
      case 'pharmacy':
        return est.pharmacies;
      case 'hospital':
        return est.hospitals;
      case 'clinic':
        return est.clinics;
      default:
        return est.establishments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<LocationProvider, EstablishmentsProvider>(
        builder: (context, locationProvider, establishmentsProvider, child) {
          final userLat = locationProvider.userLatitude;
          final userLon = locationProvider.userLongitude;

          if (locationProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A56DB)),
                  SizedBox(height: 16),
                  Text(
                    'Buscando tu ubicación...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (userLat == 0 && userLon == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      locationProvider.errorMessage ??
                          'No pudimos obtener tu ubicación.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => locationProvider.getUserLocation(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Reintentar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final establishments = _filteredEstablishments(establishmentsProvider);

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(userLat, userLon),
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),

              // Header flotante
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mapa Interactivo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF030213),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'd \'de\' MMMM',
                                      'es_ES',
                                    ).format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF717182),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A56DB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Todos', 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Farmacias', 'pharmacy'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Hospitales', 'hospital'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Clínicas', 'clinic'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Panel inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              establishmentsProvider.isLoading
                                  ? 'Buscando...'
                                  : 'Cerca de ti (${establishments.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF030213),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A56DB).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Color(0xFF1A56DB),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Toca un marcador',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1A56DB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: establishmentsProvider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1A56DB),
                                ),
                              )
                            : establishmentsProvider.errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.wifi_off,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          establishmentsProvider.errorMessage!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : establishments.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              color: Colors.grey[400],
                                              size: 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No hay establecimientos cercanos',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: establishments.length,
                                        itemBuilder: (context, index) {
                                          return _buildEstablishmentItem(
                                            establishments[index],
                                          );
                                        },
                                      ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () => _filterEstablishments(type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A56DB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A56DB)
                : const Color(0xFFE0E0E0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF030213),
          ),
        ),
      ),
    );
  }

  Widget _buildEstablishmentItem(Location establishment) {
    IconData iconData;
    Color iconColor;

    if (establishment.type == 'pharmacy') {
      iconData = Icons.local_pharmacy;
      iconColor = Colors.green;
    } else if (establishment.type == 'hospital') {
      iconData = Icons.local_hospital;
      iconColor = Colors.red;
    } else {
      iconData = Icons.medical_services;
      iconColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  establishment.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF030213),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  establishment.address.isNotEmpty
                      ? establishment.address
                      : '${establishment.distance.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF717182)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (establishment.hours.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    establishment.hours,
                    style: TextStyle(
                      fontSize: 11,
                      color: establishment.hours == 'Abierto ahora'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${establishment.distance.toStringAsFixed(1)} km',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A56DB),
            ),
          ),
        ],
      ),
    );
  }
}
