import 'package:flutter_test/flutter_test.dart';

import 'package:spawner/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const SpawnerApp());
    expect(find.text('Spawner'), findsOneWidget);
  });
}
