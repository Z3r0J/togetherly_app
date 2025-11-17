import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/counter_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'views/counter_view.dart';
import 'views/component_catalog_view.dart';
import 'views/login_view.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Togetherly App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoginView(), // Cambiar a LoginView
      ),
    );
  }
}

/// Pantalla principal con acceso al catálogo de componentes
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Togetherly')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎨 Togetherly Widget Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComponentCatalog(),
                  ),
                );
              },
              child: const Text('Ver Catálogo de Componentes'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CounterView()),
                );
              },
              child: const Text('Ver Ejemplo MVVM'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: const Text('Ver Login'),
            ),
          ],
        ),
      ),
    );
  }
}
