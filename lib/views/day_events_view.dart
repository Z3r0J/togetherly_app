import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'create_event_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Vista que muestra los eventos de un día específico.
/// Reutiliza `CompactEventCard`, `EventCard`, `ConflictBanner` y `AppButton`.
class DayEventsView extends StatelessWidget {
  const DayEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado mes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(  
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('October 2024', style: AppTextStyles.titleLarge),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // Sheet-like container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 6,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        // Fecha y conteo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Friday, October 18 • 3 events',
                                style: AppTextStyles.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Add Event pill (custom style to match maqueta)
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateEventView()),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add, color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Text('Add Event', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Lista de eventos (ejemplos estáticos imitando la maqueta)
                        Column(
                          children: [
                            // Team Standup - tarjeta grande con footer de conflicto personalizado
                            EventCard(
                              title: 'Team Standup',
                              date: 'Friday, October 18',
                              time: '9:00 AM - 9:15 AM',
                              location: 'Remote (Google Meet)',
                              rsvpStatus: null,
                              attendeeCount: null,
                              circleLabel: null,
                              circleColor: AppColors.circleOrange,
                              hasConflict: false, // manejamos el banner abajo para ajustar estilos
                              onTap: () {},
                              onViewDetails: () {},
                            ),
                            const SizedBox(height: 8),
                            // Custom conflict footer to match maqueta (orange border + Resolve in purple)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Conflicts with "Family Movie Night"', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning)),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text('Resolve', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Family Movie Night (compact card with RSVP not going + conflict)
                            CompactEventCard(
                              title: 'Family Movie Night',
                              time: '7:30 PM - 9:30 PM',
                              location: 'Home',
                              colorTag: AppColors.circlePink,
                              rsvpStatus: RsvpStatus.notGoing,
                              hasConflict: true,
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),

                            // Book Club Meeting
                            CompactEventCard(
                              title: 'Book Club Meeting',
                              time: '5:00 PM - 6:00 PM',
                              location: null,
                              colorTag: AppColors.circleTeal,
                              rsvpStatus: RsvpStatus.going,
                              hasConflict: false,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
