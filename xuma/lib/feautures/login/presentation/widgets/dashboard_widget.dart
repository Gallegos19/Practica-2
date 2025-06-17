import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/login/presentation/widgets/storage_debug_widget.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserProfileLoaded) {
          if (state.profile == null) {
            return _buildNoProfileView(context);
          }
          return _buildProfileView(context, state.profile!);
        }

        if (state is UserProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UserProfileCubit>().loadProfile(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Estado desconocido'));
      },
    );
  }

  Widget _buildNoProfileView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay perfil creado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu perfil para comenzar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear Perfil'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(profile),
          const SizedBox(height: 24),
          _buildProgressSection(context, profile),
          StorageDebugWidget(), // Integración del widget de debug
        ],
      ),
    );
  }

  Widget _buildProfileCard(profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    profile.nombre.isNotEmpty ? profile.nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.correoElectronico,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.cake, 'Edad', '${profile.edad} años'),
            _buildInfoRow(Icons.school, 'Educación', profile.nivelEducativo),
            _buildInfoRow(Icons.location_on, 'Ubicación', profile.ubicacionGeografica),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progreso en Actividades',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (profile.progresoActividades.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'No hay actividades registradas',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddActivityDialog(context),
                    child: const Text('Agregar Actividad'),
                  ),
                ],
              ),
            ),
          )
        else
          ...profile.progresoActividades.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(entry.key),
                subtitle: LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    entry.value >= 75 ? Colors.green : 
                    entry.value >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
                trailing: Text(
                  '${entry.value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _showUpdateProgressDialog(context, entry.key, entry.value),
              ),
            );
          }).toList(),
        if (profile.progresoActividades.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _showAddActivityDialog(context),
                child: const Text('Agregar Nueva Actividad'),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final actividadController = TextEditingController();
    final progresoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actividadController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la actividad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: progresoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Progreso (0-100)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final actividad = actividadController.text.trim();
              final progreso = double.tryParse(progresoController.text) ?? 0;
              
              if (actividad.isNotEmpty && progreso >= 0 && progreso <= 100) {
                context.read<UserProfileCubit>().updateProgress(actividad, progreso);
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, String actividad, double currentProgress) {
    final progresoController = TextEditingController(text: currentProgress.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Actualizar: $actividad'),
        content: TextField(
          controller: progresoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nuevo progreso (0-100)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final progreso = double.tryParse(progresoController.text) ?? 0;
              
              if (progreso >= 0 && progreso <= 100) {
                context.read<UserProfileCubit>().updateProgress(actividad, progreso);
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}