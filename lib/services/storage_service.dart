import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:spawner/models/project_config.dart';

class StorageService {
  static const _FILE_NAME = 'spawner_projects.json';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_FILE_NAME');
  }

  Future<List<ProjectConfig>> loadProjects() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
    return jsonList.map((e) => ProjectConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveProjects(List<ProjectConfig> projects) async {
    final file = await _getFile();
    final jsonList = projects.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
