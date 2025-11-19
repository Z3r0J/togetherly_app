import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/counter_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/circle_view_model.dart';
import 'views/counter_view.dart';
import 'views/component_catalog_view.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';
import 'widgets/auth_wrapper.dart';
import 'theme/app_theme.dart';
import 'services/deep_link_service.dart';
import 'models/magic_link_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinking();
  }

  Future<void> _initializeDeepLinking() async {
    _deepLinkService.onAuthLinkReceived = (DeepLinkAuthData authData) async {
      // Get AuthViewModel from context
      final authViewModel = navigatorKey.currentContext?.read<AuthViewModel>();

      if (authViewModel != null) {
        final success = await authViewModel.handleDeepLinkAuth(
          authData.accessToken,
          authData.refreshToken,
        );

        if (success && navigatorKey.currentContext != null) {
          // Navigate to dashboard after successful authentication
          final user = authViewModel.currentUser;
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  DashboardView(userName: user?.name ?? 'Usuario'),
            ),
            (route) => false,
          );

          // Show success message
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('¡Autenticación exitosa!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (navigatorKey.currentContext != null) {
          // Show error message
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                authViewModel.errorMessage ?? 'Error al autenticar',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    };

    _deepLinkService.onError = (String error) {
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    };

    await _deepLinkService.initialize();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CircleViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Togetherly App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(
          authenticatedChild: const DashboardView(userName: 'Usuario'),
          unauthenticatedChild: const LoginView(),
        ),
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
