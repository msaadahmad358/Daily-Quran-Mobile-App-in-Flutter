import 'dart:io';

import 'package:image/image.dart' as img;

/// Recolors nav PNG silhouettes to app theme green (#1A5F4A), keeps alpha.
void main() {
  const names = [
    'nav_home',
    'nav_quran',
    'nav_prayer',
    'nav_more',
    'nav_settings',
  ];
  const r = 0x1A;
  const g = 0x5F;
  const b = 0x4A;

  for (final name in names) {
    final file = File('assets/nav/$name.png');
    if (!file.existsSync()) {
      stderr.writeln('Missing: ${file.path}');
      continue;
    }
    final decoded = img.decodeImage(file.readAsBytesSync());
    if (decoded == null) {
      stderr.writeln('Decode failed: ${file.path}');
      continue;
    }
    for (var y = 0; y < decoded.height; y++) {
      for (var x = 0; x < decoded.width; x++) {
        final p = decoded.getPixel(x, y);
        final a = p.a.toInt();
        if (a < 24) {
          decoded.setPixelRgba(x, y, 0, 0, 0, 0);
          continue;
        }
        decoded.setPixelRgba(x, y, r, g, b, a);
      }
    }
    file.writeAsBytesSync(img.encodePng(decoded));
    stdout.writeln('Recolored ${file.path}');
  }
}
