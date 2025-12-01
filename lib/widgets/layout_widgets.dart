import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Header de sección con título y acción opcional
///
/// Ejemplo de uso:
/// ```dart
/// SectionHeader(
///   title: 'Your Circles',
///   actionLabel: 'See All',
///   onActionPressed: () => print('See all circles'),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Título de la sección
  final String title;

  /// Etiqueta de la acción
  final String? actionLabel;

  /// Callback para la acción
  final VoidCallback? onActionPressed;

  /// Ícono opcional
  final IconData? icon;

  /// Estilo del título
  final TextStyle? titleStyle;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.icon,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: titleStyle ?? AppTextStyles.headlineSmall,
            ),
          ),
          if (actionLabel != null && onActionPressed != null)
            TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Tabs personalizados para filtros
///
/// Ejemplo de uso:
/// ```dart
/// FilterTabs(
///   tabs: ['All', 'Personal', 'Going', 'Maybe'],
///   selectedIndex: 0,
///   onTabSelected: (index) => print('Selected: $index'),
/// )
/// ```
class FilterTabs extends StatelessWidget {
  /// Lista de etiquetas de tabs
  final List<String> tabs;

  /// Índice del tab seleccionado
  final int selectedIndex;

  /// Callback cuando se selecciona un tab
  final ValueChanged<int>? onTabSelected;

  const FilterTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onTabSelected?.call(index);
                }
              },
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Encabezado de bienvenida con saludo y fecha
///
/// Ejemplo de uso:
/// ```dart
/// WelcomeHeader(
///   userName: 'Sarah',
///   date: 'Today, October 18',
///   avatarUrl: '...',
/// )
/// ```
class WelcomeHeader extends StatelessWidget {
  /// Nombre del usuario
  final String userName;

  /// Fecha a mostrar
  final String date;

  /// URL del avatar
  final String? avatarUrl;

  /// Callback para notificaciones
  final VoidCallback? onNotificationPressed;

  /// Número de notificaciones sin leer
  final int? unreadCount;

  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.date,
    this.avatarUrl,
    this.onNotificationPressed,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 12),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName',
                  style: AppTextStyles.welcomeTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Botón de notificaciones
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: onNotificationPressed,
                color: Theme.of(context).colorScheme.onSurface,
                iconSize: 28,
              ),
              if (unreadCount != null && unreadCount! > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount! > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header de página con título y botón de regreso
///
/// Ejemplo de uso:
/// ```dart
/// PageHeader(
///   title: 'Family Get-Together',
///   subtitle: 'Family',
///   onBackPressed: () => Navigator.pop(context),
/// )
/// ```
class PageHeader extends StatelessWidget {
  /// Título principal
  final String title;

  /// Subtítulo opcional
  final String? subtitle;

  /// Callback para el botón de regreso
  final VoidCallback? onBackPressed;

  /// Callback para el menú de acciones
  final VoidCallback? onMenuPressed;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Botón de regreso
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            color: Theme.of(context).colorScheme.onSurface,
          ),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subtitle!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Menú de acciones
          if (onMenuPressed != null)
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: onMenuPressed,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        ],
      ),
    );
  }
}

/// Divisor con texto
///
/// Ejemplo de uso:
/// ```dart
/// DividerWithText(text: 'or')
/// ```
class DividerWithText extends StatelessWidget {
  /// Texto a mostrar
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Empty state genérico
///
/// Ejemplo de uso:
/// ```dart
/// EmptyState(
///   icon: Icons.event_busy,
///   title: 'No events yet',
///   message: 'Create your first event to get started',
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Ícono a mostrar
  final IconData icon;

  /// Título del estado vacío
  final String title;

  /// Mensaje descriptivo
  final String message;

  /// Etiqueta del botón de acción
  final String? actionLabel;

  /// Callback para la acción
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
