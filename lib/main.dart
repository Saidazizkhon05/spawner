import 'package:flutter/material.dart';

import 'package:spawner/app.dart';
import 'package:spawner/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(SpawnerApp(storage: storage));
}
