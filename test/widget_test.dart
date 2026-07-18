import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    // Provide empty AssetManifest.json so google_fonts doesn't crash
    final manifestJson = json.encode(const <String, dynamic>{});
    final manifestBytes = Uint8List.fromList(utf8.encode(manifestJson));
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        return manifestBytes.buffer.asByteData();
      },
    );

    await tester.pumpWidget(const ProviderScope(child: FitTrackApp()));
    await tester.pump();

    // Verify that the app launches and shows the splash screen.
    expect(find.text('FitTrack Pro'), findsOneWidget);

    // Advance the timer by 3 seconds to complete splash screen navigation and prevent timer leaks
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
  });
}