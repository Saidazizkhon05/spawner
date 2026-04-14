import 'dart:io';

class AppDiscoveryService {
  static const _APP_DIRS = [
    '/Applications',
    '/System/Applications',
    '/System/Applications/Utilities',
  ];

  Future<List<String>> getInstalledApps() async {
    final apps = <String>{};

    final homeDir = Platform.environment['HOME'];
    final dirs = [..._APP_DIRS, if (homeDir != null) '$homeDir/Applications'];

    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;

      await for (final entity in dir.list()) {
        if (entity is Directory && entity.path.endsWith('.app')) {
          final name = entity.path.split('/').last.replaceAll('.app', '');
          apps.add(name);
        }
      }
    }

    final sorted = apps.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }
}
