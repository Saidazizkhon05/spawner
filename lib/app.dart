import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spawner/cubits/projects_cubit.dart';
import 'package:spawner/screens/home_screen.dart';
import 'package:spawner/services/launcher_service.dart';
import 'package:spawner/services/storage_service.dart';
import 'package:spawner/services/tray_service.dart';
import 'package:spawner/theme/spawner_theme.dart';

class SpawnerApp extends StatefulWidget {
  const SpawnerApp({super.key});

  @override
  State<SpawnerApp> createState() => _SpawnerAppState();
}

class _SpawnerAppState extends State<SpawnerApp> {
  final _storage = StorageService();
  final _launcher = LauncherService();
  final _tray = TrayService();
  late final ProjectsCubit _projectsCubit;

  @override
  void initState() {
    super.initState();
    _projectsCubit = ProjectsCubit(storage: _storage, launcher: _launcher);
    _init();
  }

  Future<void> _init() async {
    await _tray.init();
    await _projectsCubit.load();

    // Keep tray menu in sync with projects
    _projectsCubit.stream.listen((state) {
      if (state is ProjectsLoaded) {
        _tray.updateMenu(state.projects);
      }
    });

    // Also update tray with initial data
    final state = _projectsCubit.state;
    if (state is ProjectsLoaded) {
      await _tray.updateMenu(state.projects);
    }
  }

  @override
  void dispose() {
    _projectsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _projectsCubit,
      child: MaterialApp(
        title: 'Spawner',
        debugShowCheckedModeBanner: false,
        theme: SpawnerTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
