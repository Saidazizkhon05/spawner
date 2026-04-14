import 'package:hive/hive.dart';

class ProjectConfig extends HiveObject {
  final String id;
  final String name;
  final String projectPath;
  final bool openVscode;
  final List<String> vscodeFiles;
  final bool openIterm;
  final bool openClaude;
  final List<String> additionalApps;

  ProjectConfig({
    required this.id,
    required this.name,
    required this.projectPath,
    this.openVscode = true,
    this.vscodeFiles = const [],
    this.openIterm = true,
    this.openClaude = false,
    this.additionalApps = const [],
  });

  ProjectConfig copyWith({
    String? id,
    String? name,
    String? projectPath,
    bool? openVscode,
    List<String>? vscodeFiles,
    bool? openIterm,
    bool? openClaude,
    List<String>? additionalApps,
  }) {
    return ProjectConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      projectPath: projectPath ?? this.projectPath,
      openVscode: openVscode ?? this.openVscode,
      vscodeFiles: vscodeFiles ?? this.vscodeFiles,
      openIterm: openIterm ?? this.openIterm,
      openClaude: openClaude ?? this.openClaude,
      additionalApps: additionalApps ?? this.additionalApps,
    );
  }
}

class ProjectConfigAdapter extends TypeAdapter<ProjectConfig> {
  @override
  final int typeId = 0;

  @override
  ProjectConfig read(BinaryReader reader) {
    final fields = reader.readMap().cast<String, dynamic>();
    return ProjectConfig(
      id: fields['id'] as String,
      name: fields['name'] as String,
      projectPath: fields['projectPath'] as String,
      openVscode: fields['openVscode'] as bool? ?? true,
      vscodeFiles: (fields['vscodeFiles'] as List?)?.cast<String>() ?? [],
      openIterm: fields['openIterm'] as bool? ?? true,
      openClaude: fields['openClaude'] as bool? ?? false,
      additionalApps: (fields['additionalApps'] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, ProjectConfig obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'projectPath': obj.projectPath,
      'openVscode': obj.openVscode,
      'vscodeFiles': obj.vscodeFiles,
      'openIterm': obj.openIterm,
      'openClaude': obj.openClaude,
      'additionalApps': obj.additionalApps,
    });
  }
}
