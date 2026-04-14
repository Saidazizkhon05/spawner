import 'package:flutter/material.dart';

import 'package:spawner/app.dart';
import 'package:spawner/services/project_seeder.dart';
import 'package:spawner/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final seeder = ProjectSeeder(storage: storage);
  await seeder.seedIfEmpty();

  runApp(SpawnerApp(storage: storage));
}
