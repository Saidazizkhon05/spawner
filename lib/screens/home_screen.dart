import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spawner/cubits/projects_cubit.dart';
import 'package:spawner/screens/project_form_screen.dart';
import 'package:spawner/theme/spawner_colors.dart';
import 'package:spawner/widgets/project_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.8),
            radius: 1.5,
            colors: [Color(0xFF1A1040), SpawnerColors.background],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SpawnerColors.primary, SpawnerColors.primaryDim],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: SpawnerColors.primaryGlow, blurRadius: 20)],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spawner', style: Theme.of(context).textTheme.headlineLarge),
              const Text(
                'Your workspace launcher',
                style: TextStyle(color: SpawnerColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return _HoverScaleButton(
      onPressed: () => _openForm(context, null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [SpawnerColors.primary, SpawnerColors.primaryDim]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: SpawnerColors.primaryGlow, blurRadius: 15)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New Project',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectsLoading) {
          return const Center(child: CircularProgressIndicator(color: SpawnerColors.primary));
        }

        final projects = state is ProjectsLoaded
            ? state.projects
            : (state as ProjectLaunching).projects;
        final launchingId = state is ProjectLaunching ? state.launchingId : null;

        if (projects.isEmpty) return _buildEmptyState(context);

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              key: ValueKey(project.id),
              project: project,
              isLaunching: project.id == launchingId,
              onLaunch: () => context.read<ProjectsCubit>().launch(project),
              onEdit: () => _openForm(context, project),
              onDelete: () => _showDeleteDialog(context, project.id, project.name),
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SpawnerColors.surfaceLight.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: SpawnerColors.surfaceBorder),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 48,
              color: SpawnerColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No projects yet',
            style: TextStyle(
              color: SpawnerColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first project to start spawning workspaces',
            style: TextStyle(color: SpawnerColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 28),
          _buildAddButton(context),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, project) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProjectFormScreen(existing: project),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        )
        .then((result) {
          if (result != null && context.mounted) {
            context.read<ProjectsCubit>().save(result);
          }
        });
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: SpawnerColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SpawnerColors.surfaceBorder),
          ),
          title: const Text('Delete Project', style: TextStyle(color: SpawnerColors.textPrimary)),
          content: Text(
            'Remove "$name" from Spawner?',
            style: const TextStyle(color: SpawnerColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: SpawnerColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                context.read<ProjectsCubit>().delete(id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete', style: TextStyle(color: SpawnerColors.danger)),
            ),
          ],
        );
      },
    );
  }
}

class _HoverScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _HoverScaleButton({required this.onPressed, required this.child});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}
