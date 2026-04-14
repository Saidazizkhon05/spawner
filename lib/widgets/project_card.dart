import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/theme/spawner_colors.dart';
import 'package:spawner/widgets/spawn_button.dart';

class ProjectCard extends StatefulWidget {
  final ProjectConfig project;
  final bool isLaunching;
  final VoidCallback onLaunch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isLaunching,
    required this.onLaunch,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _isHovered ? SpawnerColors.surfaceLight : SpawnerColors.cardGradientStart,
                SpawnerColors.cardGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? SpawnerColors.primary.withValues(alpha: 0.4)
                  : SpawnerColors.surfaceBorder.withValues(alpha: 0.5),
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: SpawnerColors.primaryGlow.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 18),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = widget.project.name.isNotEmpty ? widget.project.name[0].toUpperCase() : '?';
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SpawnerColors.primary, SpawnerColors.primaryDim],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: SpawnerColors.primaryGlow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.project.name,
          style: const TextStyle(
            color: SpawnerColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.project.projectPath,
          style: const TextStyle(color: SpawnerColors.textMuted, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: _buildBadges()),
      ],
    );
  }

  List<Widget> _buildBadges() {
    final badges = <Widget>[];
    if (widget.project.openVscode) badges.add(_badge('VS Code', SpawnerColors.accent));
    if (widget.project.openIterm) badges.add(_badge('iTerm', SpawnerColors.launch));
    if (widget.project.openClaude) badges.add(_badge('Claude', SpawnerColors.primaryLight));
    for (final app in widget.project.additionalApps) {
      badges.add(_badge(app, SpawnerColors.textMuted));
    }
    return badges;
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpawnButton(onPressed: widget.onLaunch, isLaunching: widget.isLaunching),
        const SizedBox(width: 8),
        _iconButton(Icons.edit_rounded, SpawnerColors.textMuted, widget.onEdit),
        _iconButton(Icons.delete_rounded, SpawnerColors.danger, widget.onDelete),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        hoverColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedBuilder({super.key, required super.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
