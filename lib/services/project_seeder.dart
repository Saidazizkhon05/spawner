import 'dart:io';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/services/storage_service.dart';

class ProjectSeeder {
  final StorageService _storage;

  static const _SCAN_DIRS = ['/Users/saidazizxonyoldashev/Main/work/humblebee/active'];

  ProjectSeeder({required StorageService storage}) : _storage = storage;

  Future<int> seedIfEmpty() async {
    final existing = _storage.loadProjects();
    if (existing.isNotEmpty) return 0;

    var seeded = 0;
    for (final scanDir in _SCAN_DIRS) {
      final dir = Directory(scanDir);
      if (!await dir.exists()) continue;

      await for (final entity in dir.list()) {
        if (entity is! Directory) continue;
        final name = entity.path.split('/').last;
        if (name.startsWith('.')) continue;

        final project = ProjectConfig(
          id: '${DateTime.now().millisecondsSinceEpoch}_$seeded',
          name: name,
          projectPath: entity.path,
          openVscode: true,
          openIterm: true,
          openClaude: false,
        );

        await _storage.saveProject(project);
        seeded++;
      }
    }

    return seeded;
  }
}
