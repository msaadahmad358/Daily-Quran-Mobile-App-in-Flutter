import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled azan2.mp3 is present for in-app playback', () async {
    final data = await rootBundle.load('assets/audio/azan2.mp3');
    expect(data.lengthInBytes, greaterThan(100000));
  });
}
