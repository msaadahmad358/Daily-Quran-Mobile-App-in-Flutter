import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qrn_app/forgot_password_screen.dart';
import 'package:qrn_app/login_screen.dart';
import 'package:qrn_app/payment_history_screen.dart';
import 'package:qrn_app/translations.dart';

Widget _app(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('API messages are mapped to French', () {
    expect(Translations.apiMessage('French', 'Invalid email or password'),
        'E-mail ou mot de passe incorrect');
    expect(Translations.apiMessage('French', 'Current password is incorrect'),
        'Le mot de passe actuel est incorrect');
    expect(
        Translations.apiMessage('French', 'No account found with this email.'),
        'Aucun compte trouvé avec cet e-mail.');
    expect(
        Translations.apiMessage('French', 'some unknown text',
            fallbackKey: 'loginFailed'),
        'Échec de la connexion');
    // English keeps working.
    expect(Translations.apiMessage('English', 'Invalid email or password'),
        'Invalid email or password');
    // Unknown language falls back to English.
    expect(Translations.getText('German', 'login'),
        Translations.getText('English', 'login'));
  });

  testWidgets('Login + signup screen in French', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(LoginScreen(
      onLogin: () {},
      onSignup: () {},
      onForgotPassword: () {},
      onSkipLogin: () {},
      currentLanguage: 'French',
      isDarkMode: false,
    )));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Bon retour — poursuivez votre chemin'), findsOneWidget);
    expect(find.text('Mot de passe oublié?'), findsOneWidget);
    expect(find.text("Vous n'avez pas de compte ?"), findsOneWidget);
    expect(find.text('Vos données sont chiffrées et restent privées'),
        findsOneWidget);
    expect(find.text('Forgot Password?'), findsNothing);
    expect(find.text("Don't have an account?"), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, "S'inscrire").last);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Créez votre compte gratuit'), findsOneWidget);
    expect(find.text('Pays'), findsOneWidget);
    expect(find.text('Confirmer le mot de passe'), findsOneWidget);
    expect(find.text('Vous avez déjà un compte ?'), findsOneWidget);
    expect(find.text('Confirm Password'), findsNothing);
    expect(find.text('Country'), findsNothing);
  });

  testWidgets('Forgot password screen in French', (tester) async {
    await tester.pumpWidget(_app(const ForgotPasswordScreen(
      isDarkMode: false,
      currentLanguage: 'French',
    )));
    await tester.pump();
    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    expect(find.text('Veuillez saisir un e-mail valide'), findsOneWidget);
    expect(find.text('Please enter a valid email'), findsNothing);
  });

  testWidgets('Payment history in French (not logged in)', (tester) async {
    await tester.pumpWidget(_app(const PaymentHistoryScreen(
      currentLanguage: 'French',
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Historique des paiements'), findsOneWidget);
    expect(find.text('Non connecté. Veuillez vous connecter.'), findsOneWidget);
  });
}
