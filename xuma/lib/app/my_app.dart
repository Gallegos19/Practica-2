import 'package:flutter/material.dart';
import 'package:xuma/feautures/login/presentation/pages/dashboard_page.dart';
import 'package:xuma/feautures/login/presentation/pages/profile_form_page.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Profile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfileFormPage(),
      },
    );
  }
}