import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../pages/login_page.dart';
import 'activity_detector_widget.dart';

class AuthGuardWidget extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthGuardWidget({
    Key? key,
    required this.child,
    this.requireAuth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!requireAuth) {
      return child;
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Si está autenticado, mostrar el contenido con detector de actividad
        if (state is AuthAuthenticated) {
          return ActivityDetectorWidget(child: child);
        }
        
        // Si está cargando, mostrar indicador
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si no está autenticado, mostrar login
        return const LoginPage();
      },
    );
  }
}