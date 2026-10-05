import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qrn_app/services/quran_data_service.dart';

/// App-wide surah recitation (Alafasy 128kbps) — survives navigation until stop.
class GlobalSurahAudioService extends ChangeNotifier {
  GlobalSurahAudioService() {
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.processingStateStream.listen((state) async {
      notifyListeners();
      if (state == ProcessingState.completed &&
          _active &&
          _surahNumber != null &&
          _surahNumber! < 114) {
        final next = _surahNumber! + 1;
        await playSurah(next, displayName: await _surahLabel(next));
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  int? _surahNumber;
  String _surahName = '';
  bool _active = false;

  int? get surahNumber => _surahNumber;
  String get surahName => _surahName;
  bool get isActive => _active;
  bool get isPlaying => _player.playing;
  bool get hasPrevious => (_surahNumber ?? 0) > 1;
  bool get hasNext => (_surahNumber ?? 0) < 114 && (_surahNumber ?? 0) > 0;

  bool get showMiniPlayer => _active && _surahNumber != null;

  static String urlForSurah(int n) =>
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$n.mp3';

  Future<String> _surahLabel(int n) async {
    final svc = QuranDataService.instance;
    if (!svc.isReady) await svc.load();
    for (final key in svc.surahKeys) {
      final s = svc.surahs[key] as Map<String, dynamic>;
      final num = s['surah_number'];
      final sn = num is int ? num : int.tryParse('$num');
      if (sn == n) {
        return s['surah_name_en']?.toString() ?? 'Surah $n';
      }
    }
    return 'Surah $n';
  }

  Future<void> playSurah(int number, {String? displayName}) async {
    if (number < 1 || number > 114) return;
    _surahNumber = number;
    _surahName = displayName ?? await _surahLabel(number);
    _active = true;
    notifyListeners();
    try {
      await _player.setUrl(urlForSurah(number));
      await _player.play();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GlobalSurahAudioService play error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (!hasNext || _surahNumber == null) return;
    await playSurah(_surahNumber! + 1);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious || _surahNumber == null) return;
    await playSurah(_surahNumber! - 1);
  }

  Future<void> togglePlayPause() async {
    if (!_active) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _active = false;
    _surahNumber = null;
    _surahName = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
