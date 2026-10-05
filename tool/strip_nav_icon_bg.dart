import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Keeps saturated / colored pixels (teal & gold icon); drops black/white/gray BG.
bool _isForeground(int r, int g, int b) {
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  if (maxC == 0) return false;

  final saturation = (maxC - minC) / maxC;

  // Icon fills (teal, gold) are saturated.
  if (saturation >= 0.12) return true;

  // Near-white background
  if (maxC > 240 && minC > 225) return false;

  // Near-black / gray checkerboard / texture
  if (maxC < 88) return false;

  return false;
}

/// Makes background pixels transparent; writes PNG for bottom nav icons.
void main() {
  const names = [
    'nav_home',
    'nav_quran',
    'nav_prayer',
    'nav_more',
    'nav_settings',
  ];

  for (final name in names) {
    final jpg = File('assets/nav/$name.jpg');
    if (!jpg.existsSync()) {
      stderr.writeln('Skip (no jpg): ${jpg.path}');
      continue;
    }
    final decoded = img.decodeImage(jpg.readAsBytesSync());
    if (decoded == null) {
      stderr.writeln('Failed decode: $name');
      continue;
    }

    final out = img.Image(
      width: decoded.width,
      height: decoded.height,
      numChannels: 4,
    );

    for (var y = 0; y < decoded.height; y++) {
      for (var x = 0; x < decoded.width; x++) {
        final p = decoded.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final a = _isForeground(r, g, b) ? 255 : 0;
        out.setPixelRgba(x, y, r, g, b, a);
      }
    }

    final bounds = _trimBounds(out);
    final trimmed = img.copyCrop(
      out,
      x: bounds.left,
      y: bounds.top,
      width: math.max(1, bounds.right - bounds.left),
      height: math.max(1, bounds.bottom - bounds.top),
    );

    File('assets/nav/$name.png').writeAsBytesSync(img.encodePng(trimmed));
    stdout.writeln('Wrote assets/nav/$name.png (${trimmed.width}x${trimmed.height})');
  }
}

({int left, int top, int right, int bottom}) _trimBounds(img.Image image) {
  var left = image.width;
  var top = image.height;
  var right = 0;
  var bottom = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a.toInt() > 12) {
        left = math.min(left, x);
        top = math.min(top, y);
        right = math.max(right, x + 1);
        bottom = math.max(bottom, y + 1);
      }
    }
  }
  if (right <= left || bottom <= top) {
    return (left: 0, top: 0, right: image.width, bottom: image.height);
  }
  const pad = 4;
  return (
    left: math.max(0, left - pad),
    top: math.max(0, top - pad),
    right: math.min(image.width, right + pad),
    bottom: math.min(image.height, bottom + pad),
  );
}
