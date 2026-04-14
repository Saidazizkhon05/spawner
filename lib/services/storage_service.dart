import 'package:hive_flutter/hive_flutter.dart';

import 'package:spawner/models/project_config.dart';

class StorageService {
  static const _BOX_NAME = 'projects';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectConfigAdapter());
    await Hive.openBox<ProjectConfig>(_BOX_NAME);
  }

  Box<ProjectConfig> get _box => Hive.box<ProjectConfig>(_BOX_NAME);

  List<ProjectConfig> loadProjects() {
    return _box.values.toList();
  }

  Future<void> saveProject(ProjectConfig project) async {
    await _box.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  Future<void> saveProjects(List<ProjectConfig> projects) async {
    await _box.clear();
    for (final project in projects) {
      await _box.put(project.id, project);
    }
  }
}
