import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qrn_app/widgets/themed_asset_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('More PNG renders in dark mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF1E1E1E),
          body: ThemedAssetIcon(
            asset: 'assets/images/more/prayer_times.png',
            isDark: true,
            size: 64,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  test('prayer_times.png outer corners are transparent', () {
    final file = File('assets/images/more/prayer_times.png');
    final image = img.decodeImage(file.readAsBytesSync())!;
    int transparent = 0;
    for (final (x, y) in [
      (0, 0),
      (image.width - 1, 0),
      (0, image.height - 1),
      (image.width - 1, image.height - 1),
    ]) {
      if (image.getPixel(x, y).a.toInt() < 20) transparent++;
    }
    expect(transparent, greaterThanOrEqualTo(3));
  });
}
