import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/services/app_discovery_service.dart';

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
  final AppDiscoveryService _appDiscovery = AppDiscoveryService();
  List<String> _installedApps = [];
  bool _appsLoading = true;
  String _appSearchQuery = '';

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
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await _appDiscovery.getInstalledApps();
    setState(() {
      _installedApps = apps;
      _appsLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _vscodeFilesController.dispose();
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
                if (_appsLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search installed apps',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _appSearchQuery = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _filteredApps.map((app) {
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
                    ),
                  ),
                ],
                if (_selectedApps.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Selected (${_selectedApps.length})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedApps
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

  List<String> get _filteredApps {
    if (_appSearchQuery.isEmpty) return _installedApps;
    final query = _appSearchQuery.toLowerCase();
    return _installedApps.where((app) => app.toLowerCase().contains(query)).toList();
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
