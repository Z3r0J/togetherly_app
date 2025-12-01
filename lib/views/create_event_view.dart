import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/widgets.dart';
import '../viewmodels/personal_event_view_model.dart';
import '../viewmodels/circle_event_view_model.dart';
import '../l10n/app_localizations.dart';
import 'personal_event_form_view.dart';
import 'circle_event_form_view.dart';

class CreateEventView extends StatefulWidget {
  final String? circleId;
  final String? circleName;
  final Color? circleColor;

  const CreateEventView({
    super.key,
    this.circleId,
    this.circleName,
    this.circleColor,
  });

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.circleId != null ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.instance;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonalEventViewModel()),
        ChangeNotifierProvider(create: (_) => CircleEventViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.tr('common.button.cancel'),
              style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          leadingWidth: 100,
          title: Text(
            l10n.tr('event.create.title'),
            style: AppTextStyles.headlineSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSelector(),
              const SizedBox(height: 24),
              _selectedTabIndex == 0
                  ? PersonalEventFormView(
                      onSuccess: () => Navigator.pop(context, true),
                    )
                  : CircleEventFormView(
                      circleId: widget.circleId ?? '',
                      onSuccess: () => Navigator.pop(context, true),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    final l10n = AppLocalizations.instance;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: l10n.tr('event.create.type.personal'),
              icon: Icons.calendar_today,
              index: 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTab(
              label: l10n.tr('event.create.type.circle'),
              icon: Icons.people,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
