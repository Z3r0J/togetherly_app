import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'notifications_view.dart';
import 'my_circles_view.dart';
import 'circle_detail_view.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido de nuevo, ${widget.userName}',
                style: AppTextStyles.headlineMedium,
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
              UserAvatar(
                name: widget.userName,
                size: 56,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCirclesSection() {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCirclesView(),
                    ),
                  );
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

        // Circles horizontales
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildCircleCardItem(
                name: 'Familia',
                memberCount: 8,
                eventTitle: "Cumpleaños de mamá",
                eventDate: '20 de oct, 7:00 PM',
                color: AppColors.circleGreen,
              ),
              const SizedBox(width: 16),
              _buildCircleCardItem(
                name: 'Club de Lectura',
                memberCount: 12,
                eventTitle: "'La biblioteca de medianoche'",
                eventDate: '22 de oct, 6:30 PM',
                color: AppColors.circleOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleCardItem({
    required String name,
    required int memberCount,
    required String eventTitle,
    required String eventDate,
    required Color color,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con color y nombre
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$memberCount miembros',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Próximo evento
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
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            eventDate,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Botón Ver Círculo
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CircleDetailView(circleName: name, circleColor: color),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size.fromHeight(0),
            ),
            child: Text(
              'Ver Círculo →',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
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
}
