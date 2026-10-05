import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrn_app/services/prayer_notification_service.dart';

void main() {
  group('iOS TestFlight readiness', () {
    test('Info.plist — location, compass, background audio', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('NSLocationWhenInUseUsageDescription'));
      expect(plist, contains('NSMotionUsageDescription'));
      expect(plist, contains('UIBackgroundModes'));
      expect(plist, contains('<string>audio</string>'));
      expect(plist, contains('ITSAppUsesNonExemptEncryption'));
    });

    test('PrivacyInfo — location declared for App Store', () {
      final privacy = File('ios/Runner/PrivacyInfo.xcprivacy').readAsStringSync();
      expect(privacy, contains('NSPrivacyCollectedDataTypePreciseLocation'));
      expect(privacy, contains('NSPrivacyTracking'));
    });

    test('Podfile — permission_handler iOS macros', () {
      final podfile = File('ios/Podfile').readAsStringSync();
      expect(podfile, contains('PERMISSION_LOCATION=1'));
      expect(podfile, contains('PERMISSION_LOCATION_WHENINUSE=1'));
      expect(podfile, contains('PERMISSION_NOTIFICATIONS=1'));
      expect(podfile, contains('PERMISSION_SENSORS=1'));
    });

    test('AppDelegate — notification center delegate', () {
      final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
      expect(delegate, contains('UNUserNotificationCenter'));
      expect(delegate, contains('delegate = self'));
    });

    test('Prayer adhan — azan.caf bundled for notification sound', () {
      final caf = File('ios/Runner/azan.caf');
      expect(caf.existsSync(), isTrue);
      expect(caf.lengthSync(), greaterThan(100000));
      expect(PrayerNotificationService.iosAzanNotificationSound, 'azan.caf');
    });

    test('ExportOptions.plist for App Store upload', () {
      final exportOpts = File('ios/ExportOptions.plist');
      expect(exportOpts.existsSync(), isTrue);
      expect(exportOpts.readAsStringSync(), contains('app-store-connect'));
    });
  });
}
