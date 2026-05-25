import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/vinculacion_service.dart';

class VinculacionScreen extends StatefulWidget {
  const VinculacionScreen({super.key});

  @override
  State<VinculacionScreen> createState() => _VinculacionScreenState();
}

class _VinculacionScreenState extends State<VinculacionScreen> {
  List<Map<String, dynamic>> _pacientes = [];
  Map<String, dynamic>? _titular;
  bool _isLoading = true;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final role = auth.currentUser?.role ?? 'INDEPENDIENTE';

    try {
      if (role == 'TITULAR' || role == 'INDEPENDIENTE') {
        final pacientes = await VinculacionService.getMisPacientes();
        setState(() => _pacientes = pacientes);
      }
      if (role == 'PACIENTE') {
        final titular = await VinculacionService.getMiTitular();
        setState(() => _titular = titular);
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  Future<void> _invitar() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    try {
      await VinculacionService.invitar(email);
      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitación enviada al correo del paciente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['message'] ?? 'Error al enviar invitación'),
            backgroundColor: const Color(0xFFd4183d),
          ),
        );
      }
    }
  }

  Future<void> _desvincular(String pacienteId, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desvincular paciente'),
        content: Text('¿Desvincular a $nombre?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desvincular', style: TextStyle(color: Color(0xFFd4183d))),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await VinculacionService.desvincular(pacienteId);
      _cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentUser?.role ?? 'INDEPENDIENTE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vinculación'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoleChip(role: role),
                  const SizedBox(height: 24),
                  if (role == 'PACIENTE') _buildVistaPackente(),
                  if (role != 'PACIENTE') _buildVistaTitular(),
                ],
              ),
            ),
    );
  }

  Widget _buildVistaPackente() {
    if (_titular == null) {
      return const Center(
        child: Text('No tienes un cuidador vinculado aún.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1A56DB),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(_titular!['name'] ?? ''),
        subtitle: Text(_titular!['email'] ?? ''),
        trailing: const Icon(Icons.favorite, color: Color(0xFF10B981)),
      ),
    );
  }

  Widget _buildVistaTitular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invitar paciente por correo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _invitar,
              child: const Text('Invitar'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Mis pacientes (${_pacientes.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_pacientes.isEmpty)
          const Text('Aún no tienes pacientes vinculados.',
              style: TextStyle(color: Colors.grey))
        else
          ..._pacientes.map((p) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(Icons.elderly, color: Colors.white),
                  ),
                  title: Text(p['name'] ?? ''),
                  subtitle: Text(p['email'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.link_off, color: Color(0xFFd4183d)),
                    onPressed: () => _desvincular(p['id'].toString(), p['name'] ?? ''),
                  ),
                ),
              )),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final config = switch (role) {
      'TITULAR' => ('Titular / Cuidador', const Color(0xFF1A56DB), Icons.manage_accounts),
      'PACIENTE' => ('Paciente', const Color(0xFF10B981), Icons.elderly),
      _ => ('Independiente', Colors.grey, Icons.person_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: config.$2.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.$3, color: config.$2, size: 20),
          const SizedBox(width: 8),
          Text('Rol: ${config.$1}',
              style: TextStyle(color: config.$2, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
