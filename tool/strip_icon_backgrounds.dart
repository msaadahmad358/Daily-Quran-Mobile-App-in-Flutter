import 'dart:io';

import 'package:image/image.dart' as img;

/// Makes near-white / light gray PNG backgrounds transparent for dark-mode tinting.
void main() {
  final root = Directory('assets/images/more');
  if (!root.existsSync()) {
    stderr.writeln('Run from project root');
    exit(1);
  }

  var count = 0;
  for (final entity in root.listSync(recursive: false)) {
    if (entity is! File) continue;
    if (!entity.path.toLowerCase().endsWith('.png')) continue;
    _processFile(entity);
    count++;
  }
  stdout.writeln('Processed $count PNG files in assets/images/more');
}

void _processFile(File file) {
  final decoded = img.decodeImage(file.readAsBytesSync());
  if (decoded == null) return;

  final image = decoded.convert(numChannels: 4);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      if (_isBackground(r, g, b)) {
        image.setPixelRgba(x, y, r, g, b, 0);
      }
    }
  }

  file.writeAsBytesSync(img.encodePng(image));
}

bool _isBackground(int r, int g, int b) {
  final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final spread = maxC - minC;

  // Pure / off-white
  if (r >= 235 && g >= 235 && b >= 235) return true;
  // Light neutral gray matte
  if (r >= 200 && g >= 200 && b >= 200 && spread < 20) return true;
  // Dark neutral tile (common in exported icons)
  if (r >= 28 && r <= 55 && g >= 28 && g <= 55 && b >= 28 && b <= 55 && spread < 18) {
    return true;
  }
  return false;
}
