import 'package:flutter/material.dart';

import 'package:spawner/theme/spawner_colors.dart';

class AppChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AppChip({super.key, required this.label, required this.selected, required this.onSelected});

  @override
  State<AppChip> createState() => _AppChipState();
}

class _AppChipState extends State<AppChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onSelected(!widget.selected);
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected
                  ? SpawnerColors.primary.withValues(alpha: 0.15)
                  : (_isHovered ? SpawnerColors.surfaceLight : SpawnerColors.surface),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.selected ? SpawnerColors.primaryLight : SpawnerColors.surfaceBorder,
                width: widget.selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.selected) ...[
                  const Icon(Icons.check_circle, color: SpawnerColors.primaryLight, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.selected
                        ? SpawnerColors.primaryLight
                        : SpawnerColors.textSecondary,
                    fontSize: 13,
                    fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
