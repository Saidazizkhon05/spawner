class ProjectConfig {
  final String id;
  final String name;
  final String projectPath;
  final bool openVscode;
  final List<String> vscodeFiles;
  final bool openIterm;
  final bool openClaude;
  final List<String> additionalApps;

  const ProjectConfig({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'projectPath': projectPath,
      'openVscode': openVscode,
      'vscodeFiles': vscodeFiles,
      'openIterm': openIterm,
      'openClaude': openClaude,
      'additionalApps': additionalApps,
    };
  }

  factory ProjectConfig.fromJson(Map<String, dynamic> json) {
    return ProjectConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      projectPath: json['projectPath'] as String,
      openVscode: json['openVscode'] as bool? ?? true,
      vscodeFiles: (json['vscodeFiles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      openIterm: json['openIterm'] as bool? ?? true,
      openClaude: json['openClaude'] as bool? ?? false,
      additionalApps:
          (json['additionalApps'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
