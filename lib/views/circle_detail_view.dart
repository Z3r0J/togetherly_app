import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class CircleDetailView extends StatefulWidget {
  final String circleName;
  final Color circleColor;

  const CircleDetailView({
    super.key,
    required this.circleName,
    required this.circleColor,
  });

  @override
  State<CircleDetailView> createState() => _CircleDetailViewState();
}

class _CircleDetailViewState extends State<CircleDetailView> {
  // Datos de ejemplo de miembros
  final List<Map<String, dynamic>> _members = [
    {'name': 'Alex Roy', 'role': 'Propietario'},
    {'name': 'Jordan L.', 'role': null},
    {'name': 'Casey', 'role': null},
    {'name': 'Morgan', 'role': null},
  ];

  // Datos de ejemplo de eventos
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Fiesta BBQ Anual',
      'date': 'sábado, 17 de agosto',
      'time': '2:00 PM - 7:00 PM',
      'location': 'Patio de Alex',
      'rsvpStatus': RsvpStatus.going,
      'going': 4,
      'maybe': 1,
      'notGoing': 0,
    },
    {
      'title': 'Noche de Cine',
      'date': 'viernes, 23 de agosto',
      'time': '7:30 PM',
      'location': 'Cine Centro',
      'rsvpStatus': RsvpStatus.maybe,
      'going': 2,
      'maybe': 2,
      'notGoing': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.circleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.circleName,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: AppColors.textPrimary,
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Miembros
              _buildMembersSection(),

              const SizedBox(height: 4),

              // Sección de Próximos Eventos
              _buildUpcomingEventsSection(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón Invitar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Miembros (${_members.length})',
                style: AppTextStyles.headlineSmall,
              ),
              AppButton(
                text: '+ Invitar',
                type: AppButtonType.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo formulario de invitación...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Grid de avatares de miembros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return _buildMemberCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] as String;
    final role = member['role'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(name: name, size: 64, backgroundColor: widget.circleColor),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            name.split(' ')[0],
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (role != null)
          Flexible(
            child: Text(
              '($role)',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón Crear Evento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Próximos Eventos', style: AppTextStyles.headlineSmall),
              AppButton(
                text: '+ Crear Evento',
                type: AppButtonType.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo formulario de crear evento...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de eventos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: _upcomingEvents.asMap().entries.map((entry) {
              final event = entry.value;
              final isLastEvent = entry.key == _upcomingEvents.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLastEvent ? 0 : 16),
                child: _buildEventCard(event),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title'] as String;
    final date = event['date'] as String;
    final time = event['time'] as String;
    final location = event['location'] as String;
    final rsvpStatus = event['rsvpStatus'] as RsvpStatus;
    final going = event['going'] as int;
    final maybe = event['maybe'] as int;
    final notGoing = event['notGoing'] as int;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del evento
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Fecha
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Hora
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Ubicación
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: AppColors.border),

          const SizedBox(height: 12),

          // RSVP Status y View Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RsvpBadge(status: rsvpStatus),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mostrando detalles de $title...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Ver Detalles →',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Conteo de RSVPs
          Text(
            '$going Asistiendo • $maybe Quizás • $notGoing No va',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Círculo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo editor del círculo...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo configuración...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  'Eliminar Círculo',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Confirmando eliminación del círculo...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
