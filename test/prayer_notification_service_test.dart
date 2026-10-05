import 'package:flutter_test/flutter_test.dart';
import 'package:qrn_app/services/app_language_prefs.dart';
import 'package:qrn_app/services/prayer_notification_service.dart';
import 'package:qrn_app/services/prayer_times_cache.dart';
import 'package:qrn_app/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLanguagePrefs.set('French');
    await PrayerTimesCache.save(
      times: {
        'Fajr': '05:30',
        'Dhuhr': '12:45',
        'Asr': '15:20',
        'Maghrib': '18:10',
        'Isha': '19:40',
      },
      location: 'Paris, FR',
      hijri: '1 Ramadan 1447',
      timezone: 'Europe/Paris',
    );
  });

  test('scheduledPreview returns cached prayer times', () async {
    final preview =
        await PrayerNotificationService.instance.scheduledPreview();
    expect(preview['Fajr'], '05:30');
    expect(preview['Isha'], '19:40');
    expect(preview.length, 5);
  });

  test('French prayer alert copy uses saved language', () async {
    final title = Translations.getText('French', 'notifPrayerTitle')
        .replaceAll('{name}', Translations.getText('French', 'fajr'));
    expect(title, contains('Heure de prière'));
    expect(
      Translations.getText('French', 'notifTestTitle'),
      contains('Rappel adhan'),
    );
  });

  test('per-prayer toggles persist without scheduling (master off)', () async {
    final svc = PrayerNotificationService.instance;
    expect(await svc.isMasterEnabled(), false);

    await svc.setPrayerEnabled('Asr', false);
    expect(await svc.isPrayerEnabled('Asr'), false);
    expect(await svc.isPrayerEnabled('Maghrib'), true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notif_master', true);
    expect(await svc.isMasterEnabled(), true);
  });
}
