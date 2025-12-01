// Script final para arreglar todos los errores de const con Theme.of(context)
import 'dart:io';

void main() async {
  print('🔧 Arreglando errores de const con Theme.of(context)...\n');

  final files = await getAllDartFiles();
  int totalFixed = 0;

  for (final file in files) {
    final fixed = await fixFile(file);
    if (fixed > 0) {
      print('✏️  ${file.uri.pathSegments.last} - $fixed cambios');
      totalFixed += fixed;
    }
  }

  print('\n✅ Total: $totalFixed cambios en ${files.length} archivos');
}

Future<List<File>> getAllDartFiles() async {
  final files = <File>[];

  for (final dir in ['lib/views', 'lib/widgets']) {
    await for (final entity in Directory(dir).list(recursive: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  }

  return files;
}

Future<int> fixFile(File file) async {
  String content = await file.readAsString();
  final original = content;
  int changes = 0;

  // Patterns que necesitan arreglarse
  final fixes = [
    // Icon con Theme.of(context)
    [
      RegExp(r'Icon\(([^)]+)\),?\s*color:\s*Theme\.of\(context\)'),
      'Icon(\$1), color: Theme.of(context)',
    ],
    [
      RegExp(
        r'Icon\s*\(\s*([^,)]+),\s*color:\s*Theme\.of\(context\)\.colorScheme\.(\w+)\s*\)',
      ),
      'Icon(\$1, color: Theme.of(context).colorScheme.\$2)',
    ],

    // const TextStyle con Theme.of(context)
    [
      RegExp(
        r'const TextStyle\s*\(\s*color:\s*Theme\.of\(context\)\.colorScheme\.(\w+)\s*\)',
      ),
      'TextStyle(color: Theme.of(context).colorScheme.\$1)',
    ],

    // const AlwaysStoppedAnimation con Theme.of(context)
    [
      RegExp(
        r'const AlwaysStoppedAnimation<Color>\(Theme\.of\(context\)\.colorScheme\.(\w+)\)',
      ),
      'AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.\$1)',
    ],

    // Casos específicos adicionales
    [
      RegExp(r'color:\s*const\s+Theme\.of\(context\)'),
      'color: Theme.of(context)',
    ],
  ];

  for (final fix in fixes) {
    if (content.contains(fix[0])) {
      content = content.replaceAll(fix[0], fix[1] as String);
      changes++;
    }
  }

  if (content != original) {
    await file.writeAsString(content);
  }

  return changes;
}
