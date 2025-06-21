import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ActivityDetectorWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ActivityDetectorWidget({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ActivityDetectorWidget> createState() => _ActivityDetectorWidgetState();
}

class _ActivityDetectorWidgetState extends State<ActivityDetectorWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSessionExpired) {
          _showSessionExpiredDialog(context);
        } else if (state is AuthSessionWarning) {
          _showSessionWarningDialog(context, state);
        }
      },
      child: widget.enabled
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onUserActivity,
              onPanDown: (_) => _onUserActivity(),
              onScaleStart: (_) => _onUserActivity(),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _onUserActivity(),
                onPointerMove: (_) => _onUserActivity(),
                onPointerUp: (_) => _onUserActivity(),
                child: widget.child,
              ),
            )
          : widget.child,
    );
  }

  void _onUserActivity() {
    if (widget.enabled) {
      context.read<AuthCubit>().updateActivity();
    }
  }

  void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.timer_off, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Sesión Expirada'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_clock,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu sesión ha expirado por inactividad. Por favor, inicia sesión nuevamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showSessionWarningDialog(BuildContext context, AuthSessionWarning state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Sesión por Expirar'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 64,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Tu sesión expirará en ${state.minutesRemaining} minutos por inactividad.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Deseas continuar con tu sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().extendSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }
}