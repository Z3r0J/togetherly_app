import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'circle_detail_view.dart';
import 'create_circle_view.dart';

class MyCirclesView extends StatefulWidget {
  const MyCirclesView({super.key});

  @override
  State<MyCirclesView> createState() => _MyCirclesViewState();
}

class _MyCirclesViewState extends State<MyCirclesView> {
  // Datos de ejemplo de círculos
  final List<Map<String, dynamic>> _circles = [
    {
      'name': 'Reunión Familiar',
      'icon': Icons.groups,
      'memberCount': 5,
      'upcomingEvents': 2,
      'lastActivity': 'hace 2h',
      'color': AppColors.circlePurple,
    },
    {
      'name': 'Aventureros de Fin de Semana',
      'icon': Icons.hiking,
      'memberCount': 8,
      'upcomingEvents': 1,
      'lastActivity': 'hace 1d',
      'color': AppColors.circleGreen,
    },
    {
      'name': 'Club de Lectura',
      'icon': Icons.book,
      'memberCount': 12,
      'upcomingEvents': 4,
      'lastActivity': 'hace 5d',
      'color': AppColors.circleOrange,
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
        title: Text('Mis Círculos', style: AppTextStyles.headlineMedium),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: AppButton(
              text: '+ Crear Círculo',
              type: AppButtonType.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCircleView(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _circles.length,
        itemBuilder: (context, index) {
          final circle = _circles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCircleCard(circle),
          );
        },
      ),
    );
  }

  Widget _buildCircleCard(Map<String, dynamic> circle) {
    final name = circle['name'] as String;
    final icon = circle['icon'] as IconData;
    final memberCount = circle['memberCount'] as int;
    final upcomingEvents = circle['upcomingEvents'] as int;
    final lastActivity = circle['lastActivity'] as String;
    final color = circle['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CircleDetailView(circleName: name, circleColor: color),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono del círculo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),

                // Información del círculo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$memberCount miembros, ${upcomingEvents == 1 ? '$upcomingEvents próximo evento' : '$upcomingEvents próximos eventos'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Activo $lastActivity',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha de navegación
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
