import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spawner/cubits/app_discovery_cubit.dart';
import 'package:spawner/models/project_config.dart';
import 'package:spawner/services/app_discovery_service.dart';
import 'package:spawner/theme/spawner_colors.dart';
import 'package:spawner/widgets/app_chip.dart';
import 'package:spawner/widgets/glass_container.dart';
import 'package:spawner/widgets/spawner_toggle.dart';

class ProjectFormScreen extends StatefulWidget {
  final ProjectConfig? existing;

  const ProjectFormScreen({super.key, this.existing});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;
  late final TextEditingController _vscodeFilesController;
  late bool _openVscode;
  late bool _openIterm;
  late bool _openClaude;
  late Set<String> _selectedApps;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

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

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _vscodeFilesController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppDiscoveryCubit(service: AppDiscoveryService())..discover(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, -0.8),
              radius: 1.5,
              colors: [Color(0xFF1A1040), SpawnerColors.background],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SpawnerColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SpawnerColors.surfaceBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: SpawnerColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _isEditing ? 'Edit Project' : 'New Project',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          _SaveButton(onPressed: _save),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Project Info', Icons.folder_rounded, _buildProjectFields()),
            const SizedBox(height: 20),
            _buildSection('Developer Tools', Icons.code_rounded, _buildToolToggles()),
            const SizedBox(height: 20),
            _buildSection('Additional Apps', Icons.apps_rounded, [_buildAppSelector()]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SpawnerColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: SpawnerColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildProjectFields() {
    return [
      TextFormField(
        controller: _nameController,
        style: const TextStyle(color: SpawnerColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Project Name',
          hintText: 'e.g. Humblebee',
          prefixIcon: Icon(Icons.label_rounded, color: SpawnerColors.textMuted, size: 20),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _pathController,
        style: const TextStyle(color: SpawnerColors.textPrimary),
        decoration: const InputDecoration(
          labelText: 'Project Path',
          hintText: 'e.g. /Users/you/projects/humblebee',
          prefixIcon: Icon(Icons.folder_open_rounded, color: SpawnerColors.textMuted, size: 20),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    ];
  }

  List<Widget> _buildToolToggles() {
    return [
      SpawnerToggle(
        title: 'VS Code',
        subtitle: 'Open project folder in VS Code',
        icon: Icons.code_rounded,
        value: _openVscode,
        onChanged: (v) => setState(() => _openVscode = v),
      ),
      if (_openVscode) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: _vscodeFilesController,
          style: const TextStyle(color: SpawnerColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Specific files to open (optional)',
            hintText: 'One file path per line',
          ),
          maxLines: 3,
        ),
      ],
      const SizedBox(height: 10),
      SpawnerToggle(
        title: 'iTerm',
        subtitle: 'Open terminal at project directory',
        icon: Icons.terminal_rounded,
        value: _openIterm,
        onChanged: (v) => setState(() => _openIterm = v),
      ),
      const SizedBox(height: 10),
      SpawnerToggle(
        title: 'Claude Code',
        subtitle: 'Open Claude in iTerm at project directory',
        icon: Icons.smart_toy_rounded,
        value: _openClaude,
        onChanged: (v) => setState(() => _openClaude = v),
      ),
    ];
  }

  Widget _buildAppSelector() {
    return BlocBuilder<AppDiscoveryCubit, AppDiscoveryState>(
      builder: (context, state) {
        if (state is AppDiscoveryLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: SpawnerColors.primary, strokeWidth: 2),
            ),
          );
        }

        final loaded = state as AppDiscoveryLoaded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(color: SpawnerColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search installed apps...',
                prefixIcon: Icon(Icons.search_rounded, color: SpawnerColors.textMuted, size: 20),
              ),
              onChanged: (v) => context.read<AppDiscoveryCubit>().search(v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 220,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.85, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: loaded.filteredApps.map((app) {
                      return AppChip(
                        label: app,
                        selected: _selectedApps.contains(app),
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
            ),
            if (_selectedApps.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SpawnerColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedApps.length} selected',
                  style: const TextStyle(
                    color: SpawnerColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedApps.map((app) {
                  return _SelectedAppChip(
                    label: app,
                    onRemove: () => setState(() => _selectedApps.remove(app)),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
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

class _SaveButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [SpawnerColors.primaryLight, SpawnerColors.primary]
                  : [SpawnerColors.primary, SpawnerColors.primaryDim],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: SpawnerColors.primaryGlow, blurRadius: _hovered ? 20 : 10),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedAppChip extends StatefulWidget {
  final String label;
  final VoidCallback onRemove;

  const _SelectedAppChip({required this.label, required this.onRemove});

  @override
  State<_SelectedAppChip> createState() => _SelectedAppChipState();
}

class _SelectedAppChipState extends State<_SelectedAppChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: SpawnerColors.primary.withValues(alpha: _hovered ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SpawnerColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: SpawnerColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: widget.onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: _hovered ? SpawnerColors.danger : SpawnerColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
