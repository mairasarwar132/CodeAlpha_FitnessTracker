import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FitTrackApp()));

    // Verify that the app launches and shows the splash screen.
    expect(find.text('FitTrack Pro'), findsOneWidget);

    // Advance the timer by 3 seconds to complete splash screen navigation and prevent timer leaks
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
