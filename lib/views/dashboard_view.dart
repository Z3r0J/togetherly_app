import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/circle_view_model.dart';
import 'notifications_view.dart';
import 'login_view.dart';

class DashboardView extends StatefulWidget {
  final String userName;

  const DashboardView({super.key, required this.userName});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Personal', 'Asistiendo', 'Quizás'];

  @override
  void initState() {
    super.initState();
    // Fetch circles on dashboard load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleViewModel>().fetchCircles();
    });
  }

  Future<void> _refreshData() async {
    await context.read<CircleViewModel>().fetchCircles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo y notificación
                _buildHeader(),

                const SizedBox(height: 24),

                // Sección "Mis Círculos"
                _buildCirclesSection(),

                const SizedBox(height: 32),

                // Sección "Próximos Eventos"
                _buildUpcomingEventsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a crear evento
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido de nuevo,',
                  style: AppTextStyles.headlineMedium,
                ),
                Text(
                  widget.userName,
                  style: AppTextStyles.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoy, 18 de octubre',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar del usuario y botón de notificaciones
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsView(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _handleLogout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('Mi Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Configuración'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                child: UserAvatar(
                  name: widget.userName,
                  size: 56,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCirclesSection() {
    return Consumer<CircleViewModel>(
      builder: (context, circleViewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y "See All"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis Círculos', style: AppTextStyles.headlineSmall),
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar a ver todos los círculos
                    },
                    child: Text(
                      'Ver todo',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Circles horizontales with loading/error states
            _buildCirclesContent(circleViewModel),
          ],
        );
      },
    );
  }

  Widget _buildCirclesContent(CircleViewModel circleViewModel) {
    if (circleViewModel.isLoading) {
      return const SizedBox(
        height: 165,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (circleViewModel.state == CircleState.error) {
      return SizedBox(
        height: 165,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                circleViewModel.errorMessage ?? 'Error loading circles',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => circleViewModel.fetchCircles(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!circleViewModel.hasCircles) {
      return SizedBox(
        height: 165,
        child: Center(
          child: Text(
            'No circles yet. Create your first circle!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: circleViewModel.circles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final circle = circleViewModel.circles[index];
          return _buildCircleCardItem(
            name: circle.name,
            memberCount: circle.memberCountInt,
            eventTitle: null,
            eventDate: null,
            color: AppColors.getCircleColor(circle.color),
          );
        },
      ),
    );
  }

  Widget _buildCircleCardItem({
    required String name,
    required int memberCount,
    String? eventTitle,
    String? eventDate,
    required Color color,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con color y nombre
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '$memberCount miembros',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Próximo evento (only show if available)
          if (eventTitle != null && eventDate != null) ...[
            Text(
              'PRÓXIMO EVENTO',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              eventTitle,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              eventDate,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
          ] else ...[
            Text(
              'No upcoming events',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Botón Ver Círculo
          AppButton(
            text: 'Ver Círculo →',
            type: AppButtonType.text,
            size: AppButtonSize.small,
            fullWidth: true,
            onPressed: () {
              // TODO: Navegar a detalles del círculo
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Próximos Eventos', style: AppTextStyles.headlineSmall),
        ),

        const SizedBox(height: 16),

        // Filtros
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: _filters.map((filter) {
              final isSelected = filter == _selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Lista de eventos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildEventItem(
                title: "Cena de cumpleaños de mamá",
                date: 'OCT',
                dateNumber: '20',
                circle: 'FAMILIA',
                circleColor: AppColors.circleGreen,
                time: '7:00 PM @ The Grand Bistro',
                rsvpStatus: RsvpStatus.going,
                attendeeCount: 6,
              ),
              const SizedBox(height: 16),
              _buildEventItem(
                title: "Discusión de 'La biblioteca de medianoche'",
                date: 'OCT',
                dateNumber: '22',
                circle: 'CLUB DE LECTURA',
                circleColor: AppColors.circleOrange,
                time: '6:30 PM @ Biblioteca Central',
                rsvpStatus: RsvpStatus.maybe,
                attendeeCount: 9,
              ),
              const SizedBox(height: 16),
              _buildEventItem(
                title: 'Carrera de trail al amanecer',
                date: 'OCT',
                dateNumber: '25',
                circle: 'AVENTUREROS',
                circleColor: AppColors.circlePurple,
                time: '8:00 AM @ North Ridge Trailhead',
                rsvpStatus: RsvpStatus.going,
                attendeeCount: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem({
    required String title,
    required String date,
    required String dateNumber,
    required String circle,
    required Color circleColor,
    required String time,
    required RsvpStatus rsvpStatus,
    required int attendeeCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  dateNumber,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Contenido del evento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Círculo/Categoría
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      circle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: circleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Título
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Hora y lugar
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // RSVP y asistentes
                Row(
                  children: [
                    RsvpBadge(status: rsvpStatus),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$attendeeCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authViewModel = context.read<AuthViewModel>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authViewModel.logout();

      if (!mounted) return;

      // Navigate to login and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    }
  }
}
