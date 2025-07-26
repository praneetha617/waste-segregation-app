import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:colorful_trash_game/main.dart' as app; // Change this to your app's actual import

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Drag-and-drop flow with replay/category switch', (tester) async {
    app.main(); // Launch your app
    await tester.pumpAndSettle();

    // Simulate drag-and-drop
    final draggable = find.byKey(ValueKey('draggable_0'));
    final dropZone = find.byKey(ValueKey('drop_zone_0'));

    await tester.drag(draggable, tester.getCenter(dropZone) - tester.getCenter(draggable));
    await tester.pumpAndSettle();

    // Assert success
    final successText = find.text('Success!');
    expect(successText, findsOneWidget);

    // Tap Replay
    final replayButton = find.byKey(ValueKey('replay_button'));
    await tester.tap(replayButton);
    await tester.pumpAndSettle();

    // Tap Change Category
    final changeCategoryButton = find.byKey(ValueKey('change_category_button'));
    await tester.tap(changeCategoryButton);
    await tester.pumpAndSettle();

    // Check if new screen appears
    final categoryText = find.text('Choose a Category');
    expect(categoryText, findsOneWidget);
  });
}
