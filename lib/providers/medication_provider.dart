import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProvider extends ChangeNotifier {
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Losartán',
      dosage: '50mg',
      frequency: '1 vez al día',
      times: ['8:00 AM'],
      containerColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1A56DB),
      isTaken: false,
    ),
    Medication(
      id: '2',
      name: 'Metformina',
      dosage: '850mg',
      frequency: '2 veces al día',
      times: ['8:00 AM', '8:00 PM'],
      containerColor: const Color(0xFFF1F5FE),
      iconColor: const Color(0xFF10B981),
      isTaken: false,
    ),
    Medication(
      id: '3',
      name: 'Atorvastatina',
      dosage: '20mg',
      frequency: '1 vez al día',
      times: ['8:00 PM'],
      containerColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
      isTaken: false,
    ),
    Medication(
      id: '4',
      name: 'Omeprazol',
      dosage: '20mg',
      frequency: '1 vez al día',
      times: ['8:00 AM'],
      containerColor: const Color(0xFFFFE4E6),
      iconColor: const Color(0xFFEC4899),
      isTaken: false,
    ),
  ];

  List<Medication> get medications => [..._medications];

  // Obtener los 7 días de la semana actual
  List<Map<String, dynamic>> get weeklyAdherence {
    final today = DateTime.now();
    final days = <Map<String, dynamic>>[];
    
    // Obtener el lunes de esta semana (día 1 es lunes)
    int daysToMonday = today.weekday - 1;
    final monday = today.subtract(Duration(days: daysToMonday));
    
    final daysNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final percentage = _calculateAdherenceForDay(dayDate);
      
      days.add({
        'day': daysNames[i],
        'percentage': percentage,
        'date': dayDate,
      });
    }
    
    return days;
  }

  // Calcular adherencia para un día específico
  int _calculateAdherenceForDay(DateTime date) {
    if (_medications.isEmpty) {
      return 0;
    }
    
    // Obtener medicamentos tomados en este día
    final takenCount = _medications.where((med) {
      if (med.takenDateTime == null) return false;
      
      return med.takenDateTime!.year == date.year &&
          med.takenDateTime!.month == date.month &&
          med.takenDateTime!.day == date.day;
    }).length;
    
    final percentage = ((takenCount / _medications.length) * 100).toInt();
    return percentage;
  }

  void addMedication(Medication med) {
    _medications.add(med);
    notifyListeners();
  }

  void editMedication(String id, Medication newMed) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _medications[index] = newMed;
      notifyListeners();
    }
  }

  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void toggleMedicationTaken(String id) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index >= 0) {
      final med = _medications[index];
      med.isTaken = !med.isTaken;
      
      // Registrar fecha/hora cuando se marca como tomado
      if (med.isTaken) {
        med.takenDateTime = DateTime.now();
      } else {
        med.takenDateTime = null;
      }
      
      notifyListeners();
    }
  }

  // Obtener medicamentos tomados hoy
  int getTakenTodayCount() {
    final today = DateTime.now();
    return _medications.where((med) {
      if (med.takenDateTime == null) return false;
      final takenDate = med.takenDateTime!;
      return takenDate.year == today.year &&
          takenDate.month == today.month &&
          takenDate.day == today.day;
    }).length;
  }

  // Obtener porcentaje de adherencia hoy
  int getTodayAdherence() {
    if (_medications.isEmpty) return 0;
    final takenCount = getTakenTodayCount();
    return ((takenCount / _medications.length) * 100).toInt();
  }

  // Verificar si un medicamento fue tomado hoy
  bool isTakenToday(String medicationId) {
    final med = _medications.firstWhere((m) => m.id == medicationId, orElse: () => Medication(
      id: '',
      name: '',
      dosage: '',
      frequency: '',
      times: [],
      containerColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1A56DB),
    ));

    if (med.takenDateTime == null) return false;

    final today = DateTime.now();
    final takenDate = med.takenDateTime!;
    return takenDate.year == today.year &&
        takenDate.month == today.month &&
        takenDate.day == today.day;
  }
}