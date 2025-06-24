import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xuma/feautures/login/presentation/pages/dashboard_page.dart';
import 'package:xuma/feautures/login/presentation/pages/profile_form_page.dart';
import 'package:xuma/feautures/auth/presentation/pages/login_page.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_cubit.dart';
import 'package:xuma/feautures/auth/presentation/cubit/auth_state.dart';
import 'package:xuma/di/injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthCubit>()..initializeAuth(),
      child: MaterialApp(
        title: 'Secure Profile App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Configuración de tema personalizada
          appBarTheme: const AppBarTheme(
            elevation: 2,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Mostrar splash screen mientras se inicializa
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashScreen();
            }
            
            // Si está autenticado, ir al dashboard
            if (state is AuthAuthenticated) {
              return const DashboardPage();
            }

            // Si cuenta fue creada, ir al formulario de perfil
            if (state is AuthAccountCreated) {
              return const ProfileFormPage();
            }
            
            // Si no hay cuenta registrada o otros estados de auth, ir al login
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/profile': (context) => const ProfileFormPage(),
        },
        // Manejar rutas desconocidas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la aplicación
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.security,
                size: 60,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 32),
            
            // Título de la aplicación
            const Text(
              'Secure Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Gestión segura de perfiles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade100,
              ),
            ),
            const SizedBox(height: 48),
            
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            
            Text(
              'Iniciando aplicación...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}