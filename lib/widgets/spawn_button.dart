import 'package:flutter/material.dart';

import 'package:spawner/theme/spawner_colors.dart';

class SpawnButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLaunching;

  const SpawnButton({super.key, required this.onPressed, this.isLaunching = false});

  @override
  State<SpawnButton> createState() => _SpawnButtonState();
}

class _SpawnButtonState extends State<SpawnButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(SpawnButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLaunching) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        listenable: _pulseController,
        builder: (context, child) {
          final scale = widget.isLaunching ? _pulseAnimation.value : (_isHovered ? 1.05 : 1.0);
          return Transform.scale(scale: scale, child: child);
        },
        child: GestureDetector(
          onTap: widget.isLaunching ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isLaunching
                    ? [SpawnerColors.accent, SpawnerColors.accentLight]
                    : [SpawnerColors.launch, SpawnerColors.launchLight],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.isLaunching ? SpawnerColors.accentGlow : SpawnerColors.launchGlow,
                  blurRadius: _isHovered || widget.isLaunching ? 20 : 10,
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isLaunching ? Icons.sync : Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isLaunching ? 'Spawning...' : 'Spawn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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

class AnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedBuilder({super.key, required super.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
