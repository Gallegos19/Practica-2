import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_state.dart';


class ProfileAuthWidget extends StatefulWidget {
  const ProfileAuthWidget({Key? key}) : super(key: key);

  @override
  State<ProfileAuthWidget> createState() => _ProfileAuthWidgetState();
}

class _ProfileAuthWidgetState extends State<ProfileAuthWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCreatingAccount = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Una vez autenticado, la página se reconstruirá automáticamente
          // y mostrará el formulario de perfil
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Información explicativa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Autenticación Requerida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para gestionar tu perfil de forma segura, necesitas autenticarte con tu correo y contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Formulario de autenticación
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isCreatingAccount ? 'Crear Cuenta' : 'Iniciar Sesión',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isCreatingAccount 
                            ? 'Crea una nueva cuenta para acceder'
                            : 'Ingresa tus credenciales para continuar',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Campo de correo electrónico
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'El correo electrónico es requerido';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'La contraseña es requerida';
                          }
                          if (value!.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botón principal
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          
                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _authenticate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isCreatingAccount ? 'Crear Cuenta' : 'Iniciar Sesión',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Alternar entre login y registro
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCreatingAccount = !_isCreatingAccount;
                          });
                        },
                        child: Text(
                          _isCreatingAccount 
                              ? '¿Ya tienes cuenta? Inicia sesión'
                              : '¿No tienes cuenta? Crear nueva',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Información adicional
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, 
                                     size: 16, 
                                     color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Datos seguros:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tu información se almacena de forma encriptada y se mantiene una sesión segura con timeout automático.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _authenticate() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Por ahora, tanto para crear cuenta como para login usamos el mismo método
      // En una implementación real, aquí distinguirías entre registro y login
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}