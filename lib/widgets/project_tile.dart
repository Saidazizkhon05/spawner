import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';

class ProjectTile extends StatelessWidget {
  final ProjectConfig project;
  final VoidCallback onLaunch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectTile({
    super.key,
    required this.project,
    required this.onLaunch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            project.name[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.projectPath, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Wrap(spacing: 4, runSpacing: 4, children: _buildBadges()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: onLaunch,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: const Text('Launch'),
            ),
            const SizedBox(width: 4),
            IconButton(icon: const Icon(Icons.edit, size: 20), tooltip: 'Edit', onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBadges() {
    final badges = <Widget>[];

    if (project.openVscode) {
      badges.add(_badge('VS Code'));
    }
    if (project.openIterm) {
      badges.add(_badge('iTerm'));
    }
    if (project.openClaude) {
      badges.add(_badge('Claude'));
    }
    for (final app in project.additionalApps) {
      badges.add(_badge(app));
    }

    return badges;
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}
