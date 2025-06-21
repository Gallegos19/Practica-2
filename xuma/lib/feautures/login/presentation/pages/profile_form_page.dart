import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_state.dart';
import 'package:xuma/feautures/auth/presentation/widgets/activity_detector_widget.dart';
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
      child: ActivityDetectorWidget(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Perfil de Usuario'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              // Mostrar estado de sesión si está autenticado
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.security,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sesión activa',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
                Navigator.of(context).pushReplacementNamed('/dashboard');
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
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                // Si no está autenticado, mostrar formulario de autenticación
                if (authState is! AuthAuthenticated) {
                  return const ProfileFormWidget();
                }
                
                // Si está autenticado, mostrar formulario de perfil normal
                return const ProfileFormWidget();
              },
            ),
          ),
        ),
      ),
    );
  }
}