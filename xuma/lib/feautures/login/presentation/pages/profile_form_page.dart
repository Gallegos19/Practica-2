import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_state.dart';
import 'package:xuma/feautures/auth/presentation/widgets/activity_detector_widget.dart';
import 'package:xuma/feautures/auth/presentation/widgets/session_status_widget.dart';
import '../../../../di/injection_container.dart' as di;
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';
import '../widgets/profile_form_widget.dart';

class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<UserProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..checkSessionValidity(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated || state is AuthNoAccountRegistered) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: ActivityDetectorWidget(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Perfil de Usuario'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                // Widget de estado de sesión
                const SessionStatusWidget(),
                
                // Menú de opciones
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'dashboard':
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                        break;
                      case 'logout':
                        _showLogoutDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'dashboard',
                      child: Row(
                        children: [
                          Icon(Icons.dashboard, size: 20),
                          SizedBox(width: 8),
                          Text('Ir al Dashboard'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión', 
                               style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: BlocListener<UserProfileCubit, UserProfileState>(
              listener: (context, state) {
                if (state is UserProfileSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil guardado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Si venimos de crear cuenta, ir al dashboard
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAccountCreated) {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  }
                } else if (state is UserProfileDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil eliminado exitosamente'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is UserProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  // Barra de información de cuenta
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated || state is AuthAccountCreated) {
                        final isNewAccount = state is AuthAccountCreated;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: isNewAccount ? Colors.green.shade50 : Colors.blue.shade50,
                          child: Row(
                            children: [
                              Icon(
                                isNewAccount ? Icons.celebration : Icons.person,
                                color: isNewAccount ? Colors.green.shade700 : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isNewAccount 
                                          ? '¡Bienvenido! Cuenta creada exitosamente'
                                          : 'Editando perfil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isNewAccount ? Colors.green.shade800 : Colors.blue.shade800,
                                      ),
                                    ),
                                    Text(
                                      isNewAccount
                                          ? 'Completa tu perfil para comenzar a usar la aplicación'
                                          : 'Actualiza tu información personal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isNewAccount ? Colors.green.shade600 : Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Contenido principal del formulario
                  const Expanded(child: ProfileFormWidget()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Cerrar Sesión'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar tu sesión? Tu perfil se mantendrá guardado.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}