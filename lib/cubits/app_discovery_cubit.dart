import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spawner/services/app_discovery_service.dart';

// --- States ---

sealed class AppDiscoveryState {}

class AppDiscoveryLoading extends AppDiscoveryState {}

class AppDiscoveryLoaded extends AppDiscoveryState {
  final List<String> allApps;
  final String query;

  AppDiscoveryLoaded({required this.allApps, this.query = ''});

  List<String> get filteredApps {
    if (query.isEmpty) return allApps;
    final q = query.toLowerCase();
    return allApps.where((app) => app.toLowerCase().contains(q)).toList();
  }
}

// --- Cubit ---

class AppDiscoveryCubit extends Cubit<AppDiscoveryState> {
  final AppDiscoveryService _service;

  AppDiscoveryCubit({required AppDiscoveryService service})
    : _service = service,
      super(AppDiscoveryLoading());

  Future<void> discover() async {
    final apps = await _service.getInstalledApps();
    emit(AppDiscoveryLoaded(allApps: apps));
  }

  void search(String query) {
    final s = state;
    if (s is AppDiscoveryLoaded) {
      emit(AppDiscoveryLoaded(allApps: s.allApps, query: query));
    }
  }
}
