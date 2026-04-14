import 'package:flutter_test/flutter_test.dart';

import 'package:spawner/app.dart';
import 'package:spawner/services/storage_service.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    final storage = StorageService();
    await storage.init();
    await tester.pumpWidget(SpawnerApp(storage: storage));
    expect(find.text('Spawner'), findsOneWidget);
  });
}
