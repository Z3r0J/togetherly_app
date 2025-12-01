// Script para arreglar errores de const con Theme.of(context)
import 'dart:io';

void main() async {
  // Remover 'const' antes de Icon, Text, TextStyle cuando usan Theme.of(context)
  final patterns = [
    // Icon con Theme.of
    {
      'pattern': RegExp(
        r'Icon\(([^)]+)\)([^;]*Theme\.of\(context\)[^;]*;)',
        multiLine: true,
      ),
      'replacement': (Match m) => 'Icon(${m.group(1)})${m.group(2)}',
    },
    // const TextStyle con Theme.of
    {
      'pattern': RegExp(r'const TextStyle\(([^)]*Theme\.of\(context\)[^)]*)\)'),
      'replacement': (Match m) => 'TextStyle(${m.group(1)})',
    },
  ];

  print('🔧 Arreglando errores de const...\n');

  await processDirectory('lib/views', patterns);
  await processDirectory('lib/widgets', patterns);

  print('\n✅ Proceso completado!');
}

Future<void> processDirectory(
  String path,
  List<Map<String, dynamic>> patterns,
) async {
  final dir = Directory(path);
  if (!await dir.exists()) return;

  await for (final entity in dir.list(recursive: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity, patterns);
    }
  }
}

Future<void> processFile(File file, List<Map<String, dynamic>> patterns) async {
  try {
    String content = await file.readAsString();
    String original = content;

    for (final patternMap in patterns) {
      final pattern = patternMap['pattern'] as RegExp;
      final replacement = patternMap['replacement'] as String Function(Match);
      content = content.replaceAllMapped(pattern, replacement);
    }

    if (content != original) {
      await file.writeAsString(content);
      print('✏️  ${file.path.split(Platform.pathSeparator).last} arreglado');
    }
  } catch (e) {
    print('❌ Error: ${file.path}: $e');
  }
}
