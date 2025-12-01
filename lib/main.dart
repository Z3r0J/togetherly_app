import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'viewmodels/counter_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/circle_view_model.dart';
import 'viewmodels/event_detail_view_model.dart';
import 'viewmodels/unified_calendar_view_model.dart';
import 'viewmodels/notification_view_model.dart';
import 'views/counter_view.dart';
import 'views/component_catalog_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/dashboard_view.dart';
import 'views/join_circle_view.dart';
import 'widgets/auth_wrapper.dart';
import 'widgets/onboarding_wrapper.dart';
import 'theme/app_theme.dart';
import 'services/deep_link_service.dart';
import 'services/invitation_service.dart';
import 'models/magic_link_models.dart';
import 'models/register_models.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Usar Future para inicialización asíncrona y mostrar Splash mientras tanto  flutter build apk --debug
  final initialization = _initializeApp();
  runApp(StartupApp(initialization: initialization));
}

Future<void> _initializeApp() async {
  try {
    // On web, Firebase requires explicit FirebaseOptions. If not available, skip init gracefully.
    if (!kIsWeb) {
      await Firebase.initializeApp();
    } else {
      debugPrint(
        'ℹ️ Web detected: skipping Firebase.initializeApp due to missing FirebaseOptions',
      );
    }
    await AppLocalizations.load();
    await initializeDateFormatting('es_ES', null);
  } catch (e) {
    // Registrar error para diagnóstico
    debugPrint('🔴 Error durante inicialización: $e');
    rethrow; // Se manejará en el FutureBuilder
  }
}

class StartupApp extends StatelessWidget {
  final Future<void> initialization;
  const StartupApp({super.key, required this.initialization});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Togetherly Startup',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<void>(
        future: initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return StartupErrorScreen(error: snapshot.error.toString());
          }
          return const MyApp();
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inicializando Togetherly...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final String error;
  const StartupErrorScreen({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al iniciar la app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Reintentar: reconstruir FutureBuilder creando nuevo Future
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          StartupApp(initialization: _initializeApp()),
                    ),
                  );
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService();
  final InvitationService _invitationService = InvitationService();
  bool _restoredPendingInvitation = false;

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
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardView()),
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

    // Handle circle invitation deep links
    _deepLinkService.onInvitationLinkReceived = (String token) async {
      print('📧 [Main] Invitation link received');
      await _handleInvitation(token);
    };

    // Handle circle share link deep links
    _deepLinkService.onShareLinkReceived = (String shareToken) async {
      print('🔗 [Main] Share link received: $shareToken');
      await _handleShareLink(shareToken);
    };

    // Handle email verification deep links
    _deepLinkService.onEmailVerificationReceived =
        (EmailVerificationData verificationData) async {
          // Get AuthViewModel from context
          final authViewModel = navigatorKey.currentContext
              ?.read<AuthViewModel>();

          if (authViewModel != null) {
            final success = await authViewModel.handleEmailVerification(
              verificationData.accessToken,
              verificationData.refreshToken,
            );

            if (success && navigatorKey.currentContext != null) {
              // Navigate to dashboard after successful verification
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DashboardView()),
                (route) => false,
              );

              // Show success message
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                const SnackBar(
                  content: Text('¡Correo verificado exitosamente!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (navigatorKey.currentContext != null) {
              // Show error message
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(
                    authViewModel.errorMessage ??
                        'Error al verificar el correo',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        };

    await _deepLinkService.initialize();
    // After deep-link wiring, attempt to restore any pending invitation token
    await _restorePendingInvitation();
  }

  Future<void> _handleInvitation(String token) async {
    print('🔵 [Main] Processing invitation token');
    print(
      '   Token: ${token.length > 20 ? token.substring(0, 20) + "..." : token}',
    );

    // Wait for auth state to be properly checked
    if (navigatorKey.currentContext != null) {
      final authViewModel = navigatorKey.currentContext!.read<AuthViewModel>();

      // Always check auth status on deep link to ensure tokens are valid
      print('⏳ [Main] Validating authentication status...');
      await authViewModel.checkAuthStatus();
      print('   Auth check completed. State: ${authViewModel.state}');

      final isLoggedIn = authViewModel.isAuthenticated;
      print('   User authenticated: $isLoggedIn');

      if (isLoggedIn) {
        print('✅ [Main] User is logged in - accepting invitation immediately');

        // User is logged in - try to accept immediately
        final circleViewModel = navigatorKey.currentContext!
            .read<CircleViewModel>();

        try {
          print('   Calling CircleViewModel.acceptInvitation...');
          final result = await circleViewModel.acceptInvitation(token);
          print('   Result: ${result != null ? "Success" : "Null"}');

          if (result != null && navigatorKey.currentContext != null) {
            // Successfully joined circle
            print(
              '✅ [Main] Invitation accepted - Circle: ${result.circleName}',
            );

            // Show success message
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('¡Te uniste a ${result.circleName}!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate to circles list or specific circle
            // The circles list will be automatically refreshed by the viewmodel
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardView()),
              (route) => false,
            );
          } else if (navigatorKey.currentContext != null) {
            // Failed to accept invitation
            print('❌ [Main] Failed to accept invitation');
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(
                  circleViewModel.errorMessage ?? 'Error al aceptar invitación',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          print('❌ [Main] Error accepting invitation: $e');
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Error al aceptar invitación: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        print('ℹ️ [Main] User is NOT logged in - saving invitation for later');
        // User is NOT logged in - save token and show login/register with preview
        print('   Saving pending invitation...');
        await _invitationService.savePendingInvitation(token);
        print('   Token saved successfully');

        // Try to fetch invitation details to show preview
        print('   Fetching invitation details...');
        final details = await _invitationService.getInvitationDetails(token);
        print('   Details fetched: ${details != null ? "Yes" : "No"}');
        if (details != null) {
          print('   Circle: ${details.circleName}');
          print('   Invited email: ${details.invitedEmail}');
          print('   Is registered: ${details.isRegistered}');
        }

        if (navigatorKey.currentContext != null && details != null) {
          final invitationContext = {
            'circleName': details.circleName,
            'inviterName': details.inviterName,
            'invitedEmail': details.invitedEmail,
          };

          // Navigate based on whether user is registered or not
          if (details.isRegistered) {
            // User has account - show login
            print('   → Navigating to LOGIN (user is registered)');
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    LoginView(invitationContext: invitationContext),
              ),
              (route) => false,
            );
          } else {
            // User doesn't have account - show register
            print('   → Navigating to REGISTER (user is NOT registered)');
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    RegisterView(invitationContext: invitationContext),
              ),
              (route) => false,
            );
          }
        } else if (navigatorKey.currentContext != null) {
          // Fallback to login if can't fetch details
          print('   → Fallback to LOGIN (could not fetch details)');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _handleShareLink(String shareToken) async {
    print('🔗 [Main] Processing share token: $shareToken');

    // Wait for auth state to be properly checked
    if (navigatorKey.currentContext != null) {
      final authViewModel = navigatorKey.currentContext!.read<AuthViewModel>();

      // Check auth status
      print('⏳ [Main] Validating authentication status...');
      await authViewModel.checkAuthStatus();
      print('   Auth check completed. State: ${authViewModel.state}');

      final isLoggedIn = authViewModel.isAuthenticated;
      print('   User authenticated: $isLoggedIn');

      if (isLoggedIn) {
        print('✅ [Main] User is logged in - navigating to JoinCircleView');

        // User is logged in - navigate to JoinCircleView
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => JoinCircleView(shareToken: shareToken),
          ),
        );
      } else {
        print('ℹ️ [Main] User is NOT logged in - navigating to login');

        // User is NOT logged in - navigate to login
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );

        // Show message
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para unirte al círculo'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _restorePendingInvitation() async {
    if (_restoredPendingInvitation) return;
    _restoredPendingInvitation = true;

    final pendingToken = await _invitationService.getPendingInvitation();
    if (pendingToken == null) {
      return;
    }

    // Ensure we have a context to navigate
    if (navigatorKey.currentContext == null) return;

    final authViewModel = navigatorKey.currentContext!.read<AuthViewModel>();
    await authViewModel.checkAuthStatus();
    final isLoggedIn = authViewModel.isAuthenticated;

    if (isLoggedIn) {
      // If logged in, try to accept immediately like the deep-link flow
      final circleViewModel = navigatorKey.currentContext!
          .read<CircleViewModel>();
      try {
        final result = await circleViewModel.acceptInvitation(pendingToken);
        if (result != null) {
          await _invitationService.clearPendingInvitation();
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('¡Te uniste a ${result.circleName}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // On failure, keep the token so it can be retried or shown in login
        debugPrint('❌ [Main] Failed to auto-accept pending invitation: $e');
      }
      return;
    }

    // Not logged in: fetch details to show banner in login/register
    final details = await _invitationService.getInvitationDetails(pendingToken);
    if (details == null) return;

    final invitationContext = {
      'circleName': details.circleName,
      'inviterName': details.inviterName,
      'invitedEmail': details.invitedEmail,
    };

    // If the invited email already has an account, go to login; otherwise register
    if (details.isRegistered) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginView(invitationContext: invitationContext),
        ),
        (route) => false,
      );
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              RegisterView(invitationContext: invitationContext),
        ),
        (route) => false,
      );
    }
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
        ChangeNotifierProvider(create: (_) => UnifiedCalendarViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => EventDetailViewModel()),
      ],
      child: Builder(
        builder: (context) {
          // Set up notification initialization callback after providers are available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final authViewModel = context.read<AuthViewModel>();
            final notificationViewModel = context.read<NotificationViewModel>();

            // Set callback to initialize notifications after login
            authViewModel.setOnLoginSuccess(() async {
              // Skip notifications on web when Firebase is not initialized
              if (kIsWeb) {
                debugPrint(
                  'ℹ️ Web: skipping NotificationService initialization',
                );
                return;
              }
              await notificationViewModel.initialize(
                onMessageTapped: (message) {
                  // Handle notification tap - navigate to appropriate screen
                  if (message == null) return;

                  final data = (message as RemoteMessage).data;
                  final eventId = data['eventId'] as String?;
                  final circleId = data['circleId'] as String?;

                  if (eventId != null) {
                    print('🔔 Navigate to event: $eventId');
                    // TODO: Navigate to event detail
                  } else if (circleId != null) {
                    print('🔔 Navigate to circle: $circleId');
                    // TODO: Navigate to circle detail
                  }
                },
              );
            });
          });

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Togetherly App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: OnboardingWrapper(
              child: AuthWrapper(
                authenticatedChild: const DashboardView(),
                unauthenticatedChild: const LoginView(),
              ),
            ),
          );
        },
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
