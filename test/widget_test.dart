// StudiOff Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studioff_app/app/app.dart';

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: StudiOffApp(),
      ),
    );

    // Verify the app loads (landing page should show)
    expect(find.text('StudiOff'), findsWidgets);
  });
}
