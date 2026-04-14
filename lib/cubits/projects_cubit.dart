import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/services/launcher_service.dart';
import 'package:spawner/services/storage_service.dart';

// --- States ---

sealed class ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsLoaded extends ProjectsState {
  final List<ProjectConfig> projects;
  ProjectsLoaded(this.projects);
}

class ProjectLaunching extends ProjectsState {
  final List<ProjectConfig> projects;
  final String launchingId;
  ProjectLaunching(this.projects, this.launchingId);
}

// --- Cubit ---

class ProjectsCubit extends Cubit<ProjectsState> {
  final StorageService _storage;
  final LauncherService _launcher;

  ProjectsCubit({required StorageService storage, required LauncherService launcher})
    : _storage = storage,
      _launcher = launcher,
      super(ProjectsLoading());

  List<ProjectConfig> get _currentProjects {
    final s = state;
    if (s is ProjectsLoaded) return s.projects;
    if (s is ProjectLaunching) return s.projects;
    return [];
  }

  void load() {
    final projects = _storage.loadProjects();
    emit(ProjectsLoaded(projects));
  }

  Future<void> save(ProjectConfig project) async {
    await _storage.saveProject(project);
    emit(ProjectsLoaded(_storage.loadProjects()));
  }

  Future<void> delete(String id) async {
    await _storage.deleteProject(id);
    emit(ProjectsLoaded(_storage.loadProjects()));
  }

  Future<void> launch(ProjectConfig project) async {
    emit(ProjectLaunching(_currentProjects, project.id));
    await _launcher.launchProject(project);
    // Brief delay so the user sees the launching state
    await Future.delayed(const Duration(milliseconds: 800));
    emit(ProjectsLoaded(_currentProjects));
  }
}
