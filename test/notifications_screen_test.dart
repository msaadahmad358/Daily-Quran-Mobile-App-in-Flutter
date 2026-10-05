import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrn_app/notifications_screen.dart';
import 'package:qrn_app/services/global_surah_audio_service.dart';
import 'package:qrn_app/services/prayer_times_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrayerTimesCache.save(
      times: {
        'Fajr': '05:30',
        'Dhuhr': '12:45',
        'Asr': '15:20',
        'Maghrib': '18:10',
        'Isha': '19:40',
      },
      location: 'Test City',
      hijri: '',
      timezone: 'UTC',
    );
  });

  testWidgets('Notifications screen shows location and test button',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalSurahAudioService(),
        child: const MaterialApp(
          home: NotificationsScreen(
            isDarkMode: false,
            currentLanguage: 'English',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.textContaining('Test City'), findsOneWidget);
    expect(find.text('Test notification & adhan'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
  });
}
