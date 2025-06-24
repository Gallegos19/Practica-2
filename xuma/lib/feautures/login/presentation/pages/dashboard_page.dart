import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_state.dart';
import 'package:xuma/feautures/auth/presentation/widgets/activity_detector_widget.dart';
import 'package:xuma/feautures/auth/presentation/widgets/session_status_widget.dart';
import '../../../../di/injection_container.dart' as di;
import '../cubit/user_profile_cubit.dart';
import '../widgets/dashboard_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<UserProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..initializeAuth(),
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
              title: const Text('Dashboard'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                // Widget de estado de sesión
                const SessionStatusWidget(),
                
                // Botón de perfil
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.of(context).pushNamed('/profile'),
                ),
                
                // Menú de opciones
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        Navigator.of(context).pushNamed('/profile');
                        break;
                      case 'account':
                        _showAccountManagementDialog(context);
                        break;
                      case 'logout':
                        _showLogoutDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text('Editar Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'account',
                      child: Row(
                        children: [
                          Icon(Icons.manage_accounts, size: 20),
                          SizedBox(width: 8),
                          Text('Gestionar Cuenta'),
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
            body: Column(
              children: [
                // Barra de información de sesión
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
                        color: Colors.blue.shade50,
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sesión activa - Token: ${state.session.token.substring(0, 12)}...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Timeout: ${state.session.timeoutMinutes} min',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                // Contenido principal
                const Expanded(child: DashboardWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.manage_accounts, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text('Gestión de Cuenta'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Opciones de gestión de tu cuenta:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              // Mostrar información de la cuenta
              FutureBuilder<Map<String, String>?>(
                future: context.read<AuthCubit>().checkAccountExistsUseCase.repository.getStoredCredentials(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final credentials = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de la cuenta:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${credentials['email']}'),
                          Text('Nombre: ${credentials['name']}'),
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showDeleteAccountDialog(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar Cuenta'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Eliminar Cuenta'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_forever,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro de que deseas eliminar tu cuenta?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Esta acción eliminará permanentemente:\n• Tu cuenta y credenciales\n• Tu perfil y datos personales\n• Todas las sesiones activas\n\nEsta acción NO se puede deshacer.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                try {
                  // Eliminar perfil primero
                  await context.read<UserProfileCubit>().removeProfile();
                  
                  // Luego eliminar cuenta
                  await context.read<AuthCubit>().logoutUseCase.repository.deleteAccount();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cuenta eliminada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Reinicializar el estado de auth
                    context.read<AuthCubit>().initializeAuth();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar cuenta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar Definitivamente'),
            ),
          ],
        );
      },
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
            '¿Estás seguro de que deseas cerrar tu sesión? Se mantendrán tus datos de perfil y cuenta guardados.',
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