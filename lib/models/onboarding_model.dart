/// Modelo para cada slide del onboarding
class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;
  final String? emoji;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    this.emoji,
  });
}

/// Slides del onboarding de Togetherly
class OnboardingData {
  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: '¡Bienvenido a Togetherly!',
      description:
          'Planea tu vida junto a quienes más importan. Un solo calendario para coordinar planes, eventos y horarios con amigos, familia y personas cercanas.',
      imagePath: 'assets/images/onboarding/onboarding_welcome.png',
      emoji: '🎉',
    ),
    OnboardingSlide(
      title: 'Crea Círculos',
      description:
          'Organiza a tus amigos, familia o compañeros en círculos. Cada círculo es un grupo donde puedes compartir eventos y coordinar planes juntos.',
      imagePath: 'assets/images/onboarding/onboarding_circles.png',
      emoji: '👥',
    ),
    OnboardingSlide(
      title: 'Eventos Compartidos',
      description:
          'Crea eventos con fecha, hora y ubicación. Todos los miembros del círculo pueden ver, votar y coordinar el mejor horario para todos.',
      imagePath: 'assets/images/onboarding/onboarding_events.jpg',
      emoji: '📅',
    ),
    OnboardingSlide(
      title: 'Calendario Unificado',
      description:
          'Visualiza todos tus eventos personales y de círculos en un solo lugar. Detecta conflictos automáticamente y encuentra el momento perfecto para reunirse.',
      imagePath: 'assets/images/onboarding/onboarding_calendar.jpg',
      emoji: '🗓️',
    ),
    OnboardingSlide(
      title: '¡Comienza a Planear!',
      description:
          'Estás listo para coordinar tu vida con las personas que importan. Crea tu primer círculo o evento y comienza a planear juntos.',
      imagePath: 'assets/images/onboarding/onboarding_start.jpg',
      emoji: '🚀',
    ),
  ];
}
