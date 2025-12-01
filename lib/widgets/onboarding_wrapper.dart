import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/onboarding_view.dart';

/// Wrapper widget que verifica si el usuario ya vio el onboarding
/// Si no lo ha visto, muestra OnboardingView
/// Si ya lo vio, muestra el child (normalmente AuthWrapper)
class OnboardingWrapper extends StatefulWidget {
  final Widget child;

  const OnboardingWrapper({super.key, required this.child});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool? _hasSeenOnboarding;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      setState(() {
        _hasSeenOnboarding = hasSeenOnboarding;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al verificar estado de onboarding: $e');
      // En caso de error, mostrar el child directamente
      setState(() {
        _hasSeenOnboarding = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar pantalla de carga mientras se verifica
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si ya vio el onboarding (o hubo error), mostrar el child
    if (_hasSeenOnboarding == true) {
      return widget.child;
    }

    // Si no ha visto el onboarding, mostrar OnboardingView
    return const OnboardingView();
  }
}
