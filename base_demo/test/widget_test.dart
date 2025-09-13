// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:base_demo/main.dart';
import 'package:base_demo/injection_container.dart' as di;

void main() {
  setUpAll(() async {
    await di.init();
  });

  testWidgets('Book Finder app navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    await tester.pumpAndSettle(const Duration(seconds: 4));
    // Verify that our app has the bottom navigation bar with 4 tabs
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Device'), findsOneWidget);
    expect(find.text('Sensors'), findsOneWidget);

    // Verify that the search screen is displayed initially
    expect(find.text('Book Finder'), findsOneWidget);

    // Tap the Device tab and verify navigation
    await tester.tap(find.text('Device'));
    await tester.pump();

    // Verify that we're on the device info screen
    expect(find.text('Device Dashboard'), findsOneWidget);
  });
}
