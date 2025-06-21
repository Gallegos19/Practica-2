import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SessionStatusWidget extends StatefulWidget {
  const SessionStatusWidget({Key? key}) : super(key: key);

  @override
  State<SessionStatusWidget> createState() => _SessionStatusWidgetState();
}

class _SessionStatusWidgetState extends State<SessionStatusWidget> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Actualizar cada minuto para mostrar el tiempo restante
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildSessionInfo(state.session);
        } else if (state is AuthSessionWarning) {
          return _buildWarningInfo(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSessionInfo(session) {
    final minutesRemaining = session.minutesUntilExpiry;
    final isNearExpiry = minutesRemaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isNearExpiry ? Colors.orange.shade50 : Colors.green.shade50,
        border: Border.all(
          color: isNearExpiry ? Colors.orange.shade300 : Colors.green.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNearExpiry ? Icons.warning_amber : Icons.check_circle,
            size: 16,
            color: isNearExpiry ? Colors.orange.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            isNearExpiry 
                ? 'Sesión expira en $minutesRemaining min'
                : 'Sesión activa ($minutesRemaining min)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isNearExpiry ? Colors.orange.shade800 : Colors.green.shade800,
            ),
          ),
          if (isNearExpiry) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                context.read<AuthCubit>().extendSession();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Extender',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningInfo(AuthSessionWarning state) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tu sesión expirará en ${state.minutesRemaining} minutos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().extendSession();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}