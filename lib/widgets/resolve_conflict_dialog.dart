import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resolve_conflict_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A modal dialog that presents two overlapping events and actions to resolve the conflict.
class ResolveConflictDialog extends StatelessWidget {
  final String personalEventId;
  final String circleEventId;
  final String personalTitle;
  final String circleTitle;
  final String personalDate;
  final String circleDate;
  final String personalLocation;
  final String circleLocation;
  final String rsvpStatus;

  const ResolveConflictDialog({
    super.key,
    required this.personalEventId,
    required this.circleEventId,
    required this.personalTitle,
    required this.circleTitle,
    required this.personalDate,
    required this.circleDate,
    required this.personalLocation,
    required this.circleLocation,
    required this.rsvpStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResolveConflictViewModel(),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conflicto de Horario',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tienes eventos que se superponen',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(false),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Personal event card
                      if (personalEventId.isNotEmpty) ...[
                        _buildEventCard(
                          context: context,
                          title: personalTitle,
                          date: personalDate,
                          location: personalLocation,
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icons.person,
                          label: 'EVENTO PERSONAL',
                          actions: (vm) => [
                            _buildActionChip(
                              label: 'Cancelar evento',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final ok = await vm.resolveConflict(
                                        eventId: personalEventId,
                                        eventType: 'personal',
                                        action: 'cancel_personal',
                                      );
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(ok);
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // VS Divider
                      if (personalEventId.isNotEmpty &&
                          circleEventId.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).colorScheme.outline,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                                child: Text(
                                  'VS',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).colorScheme.outline,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Circle event card
                      if (circleEventId.isNotEmpty)
                        _buildEventCard(
                          context: context,
                          title: circleTitle,
                          date: circleDate,
                          location: circleLocation,
                          color: AppColors.info,
                          icon: Icons.groups_rounded,
                          label: 'EVENTO DE CÍRCULO',
                          rsvpStatus: rsvpStatus,
                          actions: (vm) => [
                            _buildActionChip(
                              label: 'Ir',
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final ok = await vm.resolveConflict(
                                        eventId: circleEventId,
                                        eventType: 'circle',
                                        action: 'change_rsvp_going',
                                      );
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(ok);
                                    },
                            ),
                            _buildActionChip(
                              label: 'Tal vez',
                              icon: Icons.help_outline,
                              color: AppColors.warning,
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final ok = await vm.resolveConflict(
                                        eventId: circleEventId,
                                        eventType: 'circle',
                                        action: 'change_rsvp_maybe',
                                      );
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(ok);
                                    },
                            ),
                            _buildActionChip(
                              label: 'No ir',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final ok = await vm.resolveConflict(
                                        eventId: circleEventId,
                                        eventType: 'circle',
                                        action: 'change_rsvp_not_going',
                                      );
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(ok);
                                    },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Footer actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(true),
                        icon: Icon(Icons.event_available),
                        label: Text('Mantener ambos eventos'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(false),
                      icon: Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        'Ver en calendario',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String title,
    required String date,
    required String location,
    required Color color,
    required IconData icon,
    required String label,
    String? rsvpStatus,
    required List<Widget> Function(ResolveConflictViewModel vm) actions,
  }) {
    return Consumer<ResolveConflictViewModel>(
      builder: (context, vm, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rsvpStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRsvpColor(rsvpStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getRsvpColor(rsvpStatus).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRsvpIcon(rsvpStatus),
                              size: 16,
                              color: _getRsvpColor(rsvpStatus),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tu RSVP: ${_getRsvpLabel(rsvpStatus)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getRsvpColor(rsvpStatus),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            date,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: actions(vm)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onPressed: onPressed,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide(color: color.withOpacity(0.3), width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Color _getRsvpColor(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return AppColors.success;
      case 'maybe':
        return AppColors.warning;
      case 'not going':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRsvpIcon(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return Icons.check_circle;
      case 'maybe':
        return Icons.help;
      case 'not going':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getRsvpLabel(String status) {
    switch (status.toLowerCase()) {
      case 'going':
        return 'Voy';
      case 'maybe':
        return 'Tal vez';
      case 'not going':
        return 'No voy';
      default:
        return status;
    }
  }
}
