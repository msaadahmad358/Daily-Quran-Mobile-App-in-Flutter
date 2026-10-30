import 'package:flutter_test/flutter_test.dart';
import 'package:qrn_app/translations.dart';

void main() {
  test('donate strings EN/FR', () {
    expect(Translations.getText('English', 'donateNow'), 'Donate Now');
    expect(Translations.getText('French', 'donateNow'), 'Faire un don');
    expect(Translations.getText('English', 'couldNotOpenDonation'),
        'Could not open the donation page');
    expect(Translations.getText('French', 'couldNotOpenDonation'),
        "Impossible d'ouvrir la page de don");
  });
}
