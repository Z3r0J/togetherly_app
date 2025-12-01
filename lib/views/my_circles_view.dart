import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../viewmodels/circle_view_model.dart';
import '../l10n/app_localizations.dart';
import 'circle_detail_view.dart';
import 'create_circle_view.dart';

class MyCirclesView extends StatefulWidget {
  const MyCirclesView({super.key});

  @override
  State<MyCirclesView> createState() => _MyCirclesViewState();
}

class _MyCirclesViewState extends State<MyCirclesView> {
  late final AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    l10n = AppLocalizations.instance;
    // Fetch circles on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleViewModel>().fetchCircles();
    });
  }

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
        title: Text(
          'Mis Círculos',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCircleView(),
                  ),
                );
                if (result == true) {
                  // Refresh circles after creation
                  context.read<CircleViewModel>().fetchCircles();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Crear'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Consumer<CircleViewModel>(
        builder: (context, circleViewModel, child) {
          if (circleViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (circleViewModel.state == CircleState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    circleViewModel.errorMessage ??
                        l10n.tr('circle.message.load_failed'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: l10n.tr('common.button.retry'),
                    type: AppButtonType.primary,
                    onPressed: () => circleViewModel.fetchCircles(),
                  ),
                ],
              ),
            );
          }

          if (!circleViewModel.hasCircles) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tr('dashboard.empty.no_circles'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: '+ Crear Círculo',
                    type: AppButtonType.primary,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCircleView(),
                        ),
                      );
                      if (result == true) {
                        // Refresh circles after creation
                        circleViewModel.fetchCircles();
                      }
                    },
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => circleViewModel.fetchCircles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: circleViewModel.circles.length,
              itemBuilder: (context, index) {
                final circle = circleViewModel.circles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCircleCard(circle),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleCard(circle) {
    final id = circle.id;
    final name = circle.name;
    final memberCount = circle.memberCountInt;
    final color = AppColors.getCircleColor(circle.color);
    final description = circle.description;

    // Default icon based on color
    IconData icon = Icons.groups;
    if (color == AppColors.circleGreen) {
      icon = Icons.hiking;
    } else if (color == AppColors.circleOrange) {
      icon = Icons.book;
    } else if (color == AppColors.circleBlue) {
      icon = Icons.sports_soccer;
    }

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
                builder: (context) => CircleDetailView(
                  circleId: id,
                  circleName: name,
                  circleColor: color,
                ),
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
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description.isNotEmpty
                            ? description
                            : '$memberCount ${l10n.tr('circle.label.members')}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
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
