import 'package:flutter/material.dart';

import 'package:spawner/theme/spawner_colors.dart';

class SpawnerToggle extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SpawnerToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SpawnerToggle> createState() => _SpawnerToggleState();
}

class _SpawnerToggleState extends State<SpawnerToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.value
                ? SpawnerColors.primaryGlow
                : (_isHovered ? SpawnerColors.surfaceLight : SpawnerColors.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.value ? SpawnerColors.primary : SpawnerColors.surfaceBorder,
              width: widget.value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.value
                      ? SpawnerColors.primary.withValues(alpha: 0.2)
                      : SpawnerColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.value ? SpawnerColors.primaryLight : SpawnerColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.value
                            ? SpawnerColors.textPrimary
                            : SpawnerColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(color: SpawnerColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: widget.value ? SpawnerColors.primary : SpawnerColors.surfaceBorder,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
