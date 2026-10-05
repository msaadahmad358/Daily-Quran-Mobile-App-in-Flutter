import 'package:flutter_test/flutter_test.dart';
import 'package:qrn_app/translations.dart';

void main() {
  test('notification translation keys exist in English and French', () {
    for (final key in [
      'notificationsTitle',
      'notifTestButton',
      'notifMaster',
      'aboutUs',
    ]) {
      expect(Translations.getText('English', key), isNot(equals(key)));
      expect(Translations.getText('French', key), isNot(equals(key)));
    }
  });
}
