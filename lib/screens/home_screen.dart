import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/screens/project_form_screen.dart';
import 'package:spawner/services/launcher_service.dart';
import 'package:spawner/widgets/project_tile.dart';

class HomeScreen extends StatelessWidget {
  final List<ProjectConfig> projects;
  final ValueChanged<ProjectConfig> onDelete;
  final ValueChanged<ProjectConfig> onSave;
  final LauncherService _launcherService = LauncherService();

  HomeScreen({super.key, required this.projects, required this.onDelete, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spawner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Project',
            onPressed: () => _openForm(context, null),
          ),
        ],
      ),
      body: projects.isEmpty ? _buildEmptyState(context) : _buildList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first project to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openForm(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectTile(
          project: project,
          onLaunch: () => _launcherService.launchProject(project),
          onEdit: () => _openForm(context, project),
          onDelete: () => onDelete(project),
        );
      },
    );
  }

  void _openForm(BuildContext context, ProjectConfig? existing) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<ProjectConfig>(builder: (_) => ProjectFormScreen(existing: existing)),
        )
        .then((result) {
          if (result != null) {
            onSave(result);
          }
        });
  }
}
