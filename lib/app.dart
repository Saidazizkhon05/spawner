import 'package:flutter/material.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/screens/home_screen.dart';
import 'package:spawner/services/storage_service.dart';
import 'package:spawner/services/tray_service.dart';

class SpawnerApp extends StatefulWidget {
  const SpawnerApp({super.key});

  @override
  State<SpawnerApp> createState() => _SpawnerAppState();
}

class _SpawnerAppState extends State<SpawnerApp> {
  final StorageService _storage = StorageService();
  final TrayService _tray = TrayService();
  List<ProjectConfig> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tray.init();
    _tray.onShowWindow = _showWindow;
    _projects = await _storage.loadProjects();
    await _tray.updateMenu(_projects);
    setState(() => _isLoading = false);
  }

  void _showWindow() {
    // The window is managed by the macOS native layer.
    // This triggers a re-show via NSApplication.
    WidgetsBinding.instance.platformDispatcher;
  }

  Future<void> _saveProject(ProjectConfig project) async {
    setState(() {
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        _projects[index] = project;
      } else {
        _projects.add(project);
      }
    });
    await _storage.saveProjects(_projects);
    await _tray.updateMenu(_projects);
  }

  Future<void> _deleteProject(ProjectConfig project) async {
    setState(() {
      _projects.removeWhere((p) => p.id == project.id);
    });
    await _storage.saveProjects(_projects);
    await _tray.updateMenu(_projects);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spawner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : HomeScreen(projects: _projects, onSave: _saveProject, onDelete: _deleteProject),
    );
  }
}
