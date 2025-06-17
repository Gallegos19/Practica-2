import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';

class ProfileFormWidget extends StatefulWidget {
  const ProfileFormWidget({Key? key}) : super(key: key);

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _edadController = TextEditingController();
  final _ubicacionController = TextEditingController();
  
  String _nivelEducativo = 'Primaria';
  
  final List<String> _nivelesEducativos = [
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Universidad',
    'Posgrado',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileLoaded && state.profile != null) {
          _loadProfileData(state.profile!);
        }
      },
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'El correo es requerido';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _edadController,
                  label: 'Edad',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'La edad es requerida';
                    }
                    final edad = int.tryParse(value!);
                    if (edad == null || edad < 1 || edad > 120) {
                      return 'Ingrese una edad válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ubicacionController,
                  label: 'Ubicación geográfica',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'La ubicación es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Perfil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                if (context.read<UserProfileCubit>().hasProfile)
                  TextButton(
                    onPressed: () => _showDeleteConfirmation(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar Perfil'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadProfileData(profile) {
    _nombreController.text = profile.nombre;
    _correoController.text = profile.correoElectronico;
    _edadController.text = profile.edad.toString();
    _ubicacionController.text = profile.ubicacionGeografica;
    _nivelEducativo = profile.nivelEducativo;
    setState(() {});
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _nivelEducativo,
      decoration: InputDecoration(
        labelText: 'Nivel educativo',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      items: _nivelesEducativos.map((nivel) {
        return DropdownMenuItem(
          value: nivel,
          child: Text(nivel),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _nivelEducativo = value!;
        });
      },
    );
  }

  void _saveProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<UserProfileCubit>().saveProfile(
        nombre: _nombreController.text,
        correoElectronico: _correoController.text,
        edad: int.parse(_edadController.text),
        nivelEducativo: _nivelEducativo,
        ubicacionGeografica: _ubicacionController.text,
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro de que desea eliminar su perfil? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<UserProfileCubit>().removeProfile();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _edadController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}