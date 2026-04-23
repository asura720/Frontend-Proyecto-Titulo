import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Datos simulados de farmacias y centros médicos
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Farmacia Central',
      'type': 'pharmacy',
      'address': 'Calle Principal 123',
      'phone': '+1 (555) 123-4567',
      'distance': '0.5 km',
      'hours': '8:00 AM - 10:00 PM',
      'icon': Icons.local_pharmacy,
    },
    {
      'name': 'Hospital San José',
      'type': 'hospital',
      'address': 'Avenida Central 456',
      'phone': '+1 (555) 987-6543',
      'distance': '1.2 km',
      'hours': 'Abierto 24h',
      'icon': Icons.local_hospital,
    },
    {
      'name': 'Farmacia Santa María',
      'type': 'pharmacy',
      'address': 'Calle Segunda 789',
      'phone': '+1 (555) 456-7890',
      'distance': '0.8 km',
      'hours': '8:00 AM - 9:00 PM',
      'icon': Icons.local_pharmacy,
    },
    {
      'name': 'Clínica de Atención',
      'type': 'clinic',
      'address': 'Avenida Principal 321',
      'phone': '+1 (555) 654-3210',
      'distance': '1.5 km',
      'hours': '8:00 AM - 6:00 PM',
      'icon': Icons.local_hospital,
    },
  ];

  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final filteredLocations = _filterType == 'all'
        ? locations
        : locations.where((loc) => loc['type'] == _filterType).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFffffff),
      body: CustomScrollView(
        slivers: [
          // Header personalizado
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A56DB),
            elevation: 0,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF1A56DB),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farmacias y Centros',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, d \'de\' MMMM yyyy', 'es_ES')
                            .format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtros
                  const Text(
                    'Filtrar por tipo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('Todos', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Farmacias', 'pharmacy'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Hospitales', 'hospital'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Clínicas', 'clinic'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lista de ubicaciones
                  const Text(
                    'Ubicaciones cercanas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filteredLocations.map((entry) {
                    final location = entry;
                    return Column(
                      children: [
                        _buildLocationCard(location),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A56DB) : const Color(0xFFf3f3f5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A56DB) : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con icono y nombre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  location['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3f3f5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        _getLocationTypeLabel(location['type']),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF030213),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                location['distance'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A56DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Información detallada
          _buildInfoRow(Icons.location_on_outlined, location['address']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, location['phone']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time_outlined, location['hours']),
          const SizedBox(height: 12),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Abriendo mapa para ${location['name']}',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Ver en mapa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A56DB)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Llamando a ${location['phone']}',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Llamar',
                    style: TextStyle(
                      color: Color(0xFF1A56DB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Color(0xFF717182),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF717182),
            ),
          ),
        ),
      ],
    );
  }

  String _getLocationTypeLabel(String type) {
    switch (type) {
      case 'pharmacy':
        return 'Farmacia';
      case 'hospital':
        return 'Hospital';
      case 'clinic':
        return 'Clínica';
      default:
        return 'Ubicación';
    }
  }
}
