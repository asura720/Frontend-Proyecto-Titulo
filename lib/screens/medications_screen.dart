import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  void _showForm(BuildContext context, [Medication? medication]) {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final dosageController = TextEditingController(text: medication?.dosage ?? '');
    final frequencyController = TextEditingController(text: medication?.frequency ?? '1 vez al día');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              medication == null ? 'Añadir Medicamento' : 'Editar Medicamento', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del medicamento',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageController,
              decoration: InputDecoration(
                labelText: 'Dosis (ej: 50mg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: frequencyController,
              decoration: InputDecoration(
                labelText: 'Frecuencia',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF030213),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final medProvider = Provider.of<MedicationProvider>(context, listen: false);
                  final newMed = Medication(
                    id: medication?.id ?? DateTime.now().toString(),
                    name: nameController.text,
                    dosage: dosageController.text,
                    frequency: frequencyController.text,
                    times: medication?.times ?? ['8:00 AM'],
                    containerColor: medication?.containerColor ?? const Color(0xFFf3f3f5),
                    iconColor: medication?.iconColor ?? const Color(0xFF030213),
                    isTaken: medication?.isTaken ?? false,
                    takenDateTime: medication?.takenDateTime,
                  );

                  if (medication == null) {
                    medProvider.addMedication(newMed);
                  } else {
                    medProvider.editMedication(medication.id, newMed);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffffff),
      body: Consumer<MedicationProvider>(
        builder: (context, medProvider, _) {
          final medications = medProvider.medications;
          
          return CustomScrollView(
            slivers: [
              // Header personalizado
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1A56DB),
                elevation: 0,
                expandedHeight: 120,
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
                            'CuidApp',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tu salud en tus manos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y contador
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mis Medicamentos',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                '${medications.length} medicamentos activos',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Resumen semanal
                      Container(
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen semanal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Gráfica de barras de la semana
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                medProvider.weeklyAdherence.length,
                                (index) {
                                  final data = medProvider.weeklyAdherence[index];
                                  final percentage = (data['percentage'] as int) / 100;
                                  
                                  return Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 80 * percentage,
                                              decoration: BoxDecoration(
                                                color: percentage == 1.0
                                                    ? const Color(0xFF10B981)
                                                    : percentage >= 0.5
                                                        ? const Color(0xFFFCD34D)
                                                        : const Color(0xFFEF4444),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data['day'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${data['percentage']}%',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título de medicamentos
                      const Text(
                        'Medicamentos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Lista de medicamentos
                      ...medications.asMap().entries.map((entry) {
                        Medication med = entry.value;
                        final isTakenToday = medProvider.isTakenToday(med.id);
                        return Column(
                          children: [
                            Container(
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: med.containerColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.medication_outlined,
                                              color: med.iconColor,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                med.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              Text(
                                                med.dosage,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          medProvider.toggleMedicationTaken(med.id);
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isTakenToday ? Colors.green : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                            color: isTakenToday ? Colors.green : Colors.transparent,
                                          ),
                                          child: isTakenToday
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF030213)),
                                            onPressed: () => _showForm(context, med),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () {
                                              medProvider.deleteMedication(med.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    med.frequency,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: med.times
                                        .map((time) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  time,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                        .toList(),
                                  ),
                                  if (isTakenToday && med.takenDateTime != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xAA10B981)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Tomado',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF10B981),
                                                  ),
                                                ),
                                                Text(
                                                  '${med.takenDateTime!.day}/${med.takenDateTime!.month} a las ${med.takenDateTime!.hour.toString().padLeft(2, '0')}:${med.takenDateTime!.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                      const SizedBox(height: 40), // Espacio para el botón flotante
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF030213),
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}