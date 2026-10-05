import 'dart:collection';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('strip PNG backgrounds in assets/images/more', () {
    final root = Directory('assets/images/more');
    expect(root.existsSync(), isTrue);

    var count = 0;
    for (final entity in root.listSync(recursive: false)) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.png')) continue;
      _processToPng(entity, File(entity.path));
      count++;
    }
    expect(count, greaterThan(5));
  });

  test('strip JPG card icons to transparent PNG', () {
    const jpgNames = [
      'read_quran.jpg',
      'history.jpg',
      'stats.jpg',
      'zakat_calculator.jpg',
      'islamic_calendar.jpg',
    ];
    for (final name in jpgNames) {
      final jpg = File('assets/images/more/$name');
      expect(jpg.existsSync(), isTrue, reason: name);
      final pngPath = jpg.path.replaceAll(RegExp(r'\.jpe?g$', caseSensitive: false), '.png');
      _processToPng(jpg, File(pngPath));
      expect(File(pngPath).existsSync(), isTrue);
    }
  });
}

void _processToPng(File input, File outputPng) {
  final decoded = img.decodeImage(input.readAsBytesSync());
  expect(decoded, isNotNull);
  final image = decoded!.convert(numChannels: 4);
  _floodClearBackground(image);
  outputPng.writeAsBytesSync(img.encodePng(image));
}

void _floodClearBackground(img.Image image) {
  final w = image.width;
  final h = image.height;
  final seen = List.generate(h, (_) => List.filled(w, false));
  final queue = Queue<(int, int)>();

  void seed(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    queue.add((x, y));
  }

  for (var x = 0; x < w; x++) {
    seed(x, 0);
    seed(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    seed(0, y);
    seed(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final (x, y) = queue.removeFirst();
    if (x < 0 || x >= w || y < 0 || y >= h) continue;
    if (seen[y][x]) continue;
    seen[y][x] = true;

    final p = image.getPixel(x, y);
    if (p.a.toInt() < 8) continue;
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    if (!_isBackground(r, g, b)) continue;

    image.setPixelRgba(x, y, r, g, b, 0);
    queue.add((x + 1, y));
    queue.add((x - 1, y));
    queue.add((x, y + 1));
    queue.add((x, y - 1));
  }
}

bool _isBackground(int r, int g, int b) {
  final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final spread = maxC - minC;
  final lum = (0.299 * r + 0.587 * g + 0.114 * b);

  if (lum >= 215 && spread < 50) return true;
  if (r >= 200 && g >= 200 && b >= 200 && spread < 25) return true;
  return false;
}
