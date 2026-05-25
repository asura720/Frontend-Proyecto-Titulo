import 'api_service.dart';

class VinculacionService {
  static Future<void> invitar(String emailPaciente) async {
    await ApiService.dio.post('/api/auth/vincular/invitar', data: {
      'emailPaciente': emailPaciente,
    });
  }

  static Future<List<Map<String, dynamic>>> getMisPacientes() async {
    final response = await ApiService.dio.get('/api/auth/vincular/mis-pacientes');
    return List<Map<String, dynamic>>.from(response.data);
  }

  static Future<Map<String, dynamic>> getMiTitular() async {
    final response = await ApiService.dio.get('/api/auth/vincular/mi-titular');
    return Map<String, dynamic>.from(response.data);
  }

  static Future<void> desvincular(String pacienteId) async {
    await ApiService.dio.delete('/api/auth/vincular/desvincular/$pacienteId');
  }
}
