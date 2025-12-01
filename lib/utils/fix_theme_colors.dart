// Script para reemplazar colores hardcodeados por colores del tema
// Ejecutar: dart run lib/utils/fix_theme_colors.dart

import 'dart:io';

void main() async {
  final replacements = {
    // Text colors
    'AppColors.textPrimary': 'Theme.of(context).colorScheme.onSurface',
    'AppColors.textSecondary': 'Theme.of(context).colorScheme.onSurfaceVariant',
    'AppColors.textTertiary':
        'Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)',
    'AppColors.textOnPrimary': 'Theme.of(context).colorScheme.onPrimary',

    // Surface colors
    'AppColors.surface': 'Theme.of(context).colorScheme.surface',
    'AppColors.background':
        'Theme.of(context).colorScheme.surfaceContainerHighest',
    'AppColors.surfaceVariant':
        'Theme.of(context).colorScheme.surfaceContainerHighest',

    // Border and other
    'AppColors.border': 'Theme.of(context).colorScheme.outline',
    'AppColors.primary': 'Theme.of(context).colorScheme.primary',
    'AppColors.primaryLight': 'Theme.of(context).colorScheme.primaryContainer',

    // Style color removals - estos deben ser más cuidadosos
    'AppTextStyles.bodyMedium.copyWith(\n    color: AppColors.textSecondary,\n  )':
        'AppTextStyles.bodyMedium',
    'AppTextStyles.bodyMedium.copyWith(\n                    color: AppColors.textSecondary,\n                  )':
        'AppTextStyles.bodyMedium',
    'AppTextStyles.bodySmall.copyWith(\n    color: AppColors.textSecondary,\n  )':
        'AppTextStyles.bodySmall',
    'AppTextStyles.labelSmall.copyWith(\n    color: AppColors.textSecondary,\n  )':
        'AppTextStyles.labelSmall',
    'AppTextStyles.labelMedium.copyWith(\n    color: AppColors.primary,\n  )':
        'AppTextStyles.labelMedium',
  };

  print('🔧 Iniciando reemplazo de colores hardcodeados...\n');

  // Procesar archivos de vistas
  await processDirectory('lib/views', replacements);

  // Procesar archivos de widgets
  await processDirectory('lib/widgets', replacements);

  print('\n✅ Proceso completado!');
}

Future<void> processDirectory(
  String path,
  Map<String, String> replacements,
) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    print('❌ Directorio no encontrado: $path');
    return;
  }

  await for (final entity in dir.list(recursive: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity, replacements);
    }
  }
}

Future<void> processFile(File file, Map<String, String> replacements) async {
  try {
    String content = await file.readAsString();
    String original = content;
    int changeCount = 0;

    for (final entry in replacements.entries) {
      final oldPattern = entry.key;
      final newPattern = entry.value;

      if (content.contains(oldPattern)) {
        content = content.replaceAll(oldPattern, newPattern);
        changeCount++;
      }
    }

    if (content != original) {
      await file.writeAsString(content);
      print(
        '✏️  ${file.path.split(Platform.pathSeparator).last} - $changeCount cambios',
      );
    }
  } catch (e) {
    print('❌ Error procesando ${file.path}: $e');
  }
}
