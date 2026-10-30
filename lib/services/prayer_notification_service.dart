import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:qrn_app/services/app_language_prefs.dart';
import 'package:qrn_app/services/prayer_times_cache.dart';
import 'package:qrn_app/translations.dart';

class PrayerNotificationService {
  PrayerNotificationService._();
  static final PrayerNotificationService instance = PrayerNotificationService._();

  static const _masterKey = 'prayer_notif_master';
  static const _prefPrefix = 'prayer_notif_';

  /// Android: `res/raw/azan2.mp3`. iOS: `Runner/azan.caf` (≤30s clip from azan2).
  static const azanSoundResource = 'azan2';
  static const iosAzanNotificationSound = 'azan.caf';
  static const _azanChannelId = 'prayer_azan_channel_azan2_v1';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _prayers = [
    ('Fajr', 101),
    ('Dhuhr', 102),
    ('Asr', 103),
    ('Maghrib', 104),
    ('Isha', 105),
  ];

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _ensureAzanChannel();
    _initialized = true;
  }

  Future<void> _ensureAzanChannel() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      AndroidNotificationChannel(
        _azanChannelId,
        'Prayer times',
        description: 'Adhan reminders for your location',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(azanSoundResource),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  DarwinNotificationDetails get _iosDetails => DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: iosAzanNotificationSound,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

  NotificationDetails _azanNotificationDetails() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          _azanChannelId,
          'Prayer times',
          channelDescription: 'Adhan reminders for your location',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(azanSoundResource),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: _iosDetails,
      );
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return NotificationDetails(iOS: _iosDetails);
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _azanChannelId,
        'Prayer times',
        channelDescription: 'Adhan reminders for your location',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: _iosDetails,
    );
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<bool> isMasterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_masterKey) ?? false;
  }

  Future<void> setMasterEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_masterKey, value);
    if (value) {
      await rescheduleFromCache();
    } else {
      await cancelAllPrayerNotifications();
    }
  }

  Future<bool> isPrayerEnabled(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefPrefix$prayer') ?? true;
  }

  Future<void> setPrayerEnabled(String prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefPrefix$prayer', value);
    if (await isMasterEnabled()) {
      await rescheduleFromCache();
    }
  }

  Future<void> cancelAllPrayerNotifications() async {
    for (final p in _prayers) {
      await _plugin.cancel(p.$2);
    }
  }

  Future<void> rescheduleFromCache() async {
    await init();
    await cancelAllPrayerNotifications();

    if (!await isMasterEnabled()) return;

    final cache = await PrayerTimesCache.load();
    if (cache == null) return;

    // Prayer times are wall-clock times in the city's timezone. If the cached
    // timezone is missing/unknown, fall back to the DEVICE's local time
    // (tz.local is UTC unless set, which would fire alerts hours off).
    tz.Location? location;
    if (cache.timezone.isNotEmpty) {
      try {
        location = tz.getLocation(cache.timezone);
      } catch (_) {
        location = null;
      }
    }

    final details = _azanNotificationDetails();
    final lang = await AppLanguagePrefs.get();

    for (final entry in _prayers) {
      final name = entry.$1;
      final id = entry.$2;
      if (!await isPrayerEnabled(name)) continue;

      final raw = cache.times[name]?.toString();
      if (raw == null || raw.isEmpty || raw == '--:--') continue;

      final when = location != null
          ? _nextPrayerDateTime(raw, location)
          : _nextPrayerDeviceLocal(raw);
      if (when == null) continue;

      final (title, body) = _localizedPrayerAlert(
        lang: lang,
        prayerKey: name,
        location: cache.location,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Next occurrence of HH:mm in the device's local time, as an absolute
  /// instant (UTC-based TZDateTime), independent of tz.local.
  tz.TZDateTime? _nextPrayerDeviceLocal(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim().split(' ').first);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    var local = DateTime(now.year, now.month, now.day, h, m);
    if (local.isBefore(now)) {
      local = DateTime(now.year, now.month, now.day + 1, h, m);
    }
    return tz.TZDateTime.from(local, tz.UTC);
  }

  tz.TZDateTime? _nextPrayerDateTime(String hhmm, tz.Location location) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    if (h == null || m == null) return null;

    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(location, now.year, now.month, now.day, h, m);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      999,
      title,
      body,
      _azanNotificationDetails(),
    );
  }

  Future<void> scheduleTestPrayerNotification({
    required String title,
    required String body,
    Duration delay = const Duration(seconds: 15),
  }) async {
    await init();
    await _plugin.cancel(998);
    final when = tz.TZDateTime.now(tz.UTC).add(delay);
    await _plugin.zonedSchedule(
      998,
      title,
      body,
      when,
      _azanNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  (String, String) _localizedPrayerAlert({
    required String lang,
    required String prayerKey,
    required String location,
  }) {
    final prayerLabel =
        Translations.getText(lang, prayerKey.toLowerCase());
    final title = Translations.getText(lang, 'notifPrayerTitle')
        .replaceAll('{name}', prayerLabel);
    final body = location.isNotEmpty
        ? Translations.getText(lang, 'notifPrayerBodyLoc')
            .replaceAll('{name}', prayerLabel)
            .replaceAll('{location}', location)
        : Translations.getText(lang, 'notifPrayerBody')
            .replaceAll('{name}', prayerLabel);
    return (title, body);
  }

  Future<Map<String, String>> scheduledPreview() async {
    final cache = await PrayerTimesCache.load();
    if (cache == null) return {};
    final out = <String, String>{};
    for (final p in _prayers) {
      final t = cache.times[p.$1]?.toString();
      if (t != null && t.isNotEmpty) out[p.$1] = t;
    }
    return out;
  }
}
