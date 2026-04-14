import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';

const List<String> COMMON_APPS = [
  'Discord',
  'Vivaldi',
  'Slack',
  'Figma',
  'Spotify',
  'Telegram',
  'Safari',
  'Google Chrome',
  'Firefox',
  'Notion',
  'Postman',
];

class ProjectFormScreen extends StatefulWidget {
  final ProjectConfig? existing;

  const ProjectFormScreen({super.key, this.existing});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;
  late final TextEditingController _vscodeFilesController;
  late bool _openVscode;
  late bool _openIterm;
  late bool _openClaude;
  late Set<String> _selectedApps;
  late final TextEditingController _customAppController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _pathController = TextEditingController(text: existing?.projectPath ?? '');
    _vscodeFilesController = TextEditingController(text: existing?.vscodeFiles.join('\n') ?? '');
    _openVscode = existing?.openVscode ?? true;
    _openIterm = existing?.openIterm ?? true;
    _openClaude = existing?.openClaude ?? false;
    _selectedApps = Set<String>.from(existing?.additionalApps ?? []);
    _customAppController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _vscodeFilesController.dispose();
    _customAppController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'New Project'),
        actions: [
          FilledButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Project Info', [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g. Humblebee',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'Project Path',
                    hintText: 'e.g. /Users/you/projects/humblebee',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Developer Tools', [
                SwitchListTile(
                  title: const Text('VS Code'),
                  subtitle: const Text('Open project folder in VS Code'),
                  value: _openVscode,
                  onChanged: (v) => setState(() => _openVscode = v),
                ),
                if (_openVscode) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _vscodeFilesController,
                    decoration: const InputDecoration(
                      labelText: 'Specific files to open (optional)',
                      hintText: 'One file path per line',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
                SwitchListTile(
                  title: const Text('iTerm'),
                  subtitle: const Text('Open terminal at project directory'),
                  value: _openIterm,
                  onChanged: (v) => setState(() => _openIterm = v),
                ),
                SwitchListTile(
                  title: const Text('Claude Code'),
                  subtitle: const Text('Open Claude in iTerm at project directory'),
                  value: _openClaude,
                  onChanged: (v) => setState(() => _openClaude = v),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Additional Apps', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: COMMON_APPS.map((app) {
                    final selected = _selectedApps.contains(app);
                    return FilterChip(
                      label: Text(app),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedApps.add(app);
                          } else {
                            _selectedApps.remove(app);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customAppController,
                        decoration: const InputDecoration(
                          labelText: 'Custom app name',
                          hintText: 'e.g. TablePlus',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: _addCustomApp),
                  ],
                ),
                if (_selectedApps.difference(COMMON_APPS.toSet()).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedApps
                        .difference(COMMON_APPS.toSet())
                        .map(
                          (app) => Chip(
                            label: Text(app),
                            onDeleted: () {
                              setState(() => _selectedApps.remove(app));
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _addCustomApp() {
    final name = _customAppController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _selectedApps.add(name);
      _customAppController.clear();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final vscodeFiles = _vscodeFilesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final project = ProjectConfig(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      projectPath: _pathController.text.trim(),
      openVscode: _openVscode,
      vscodeFiles: vscodeFiles,
      openIterm: _openIterm,
      openClaude: _openClaude,
      additionalApps: _selectedApps.toList(),
    );

    Navigator.of(context).pop(project);
  }
}
