import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrn_app/services/global_surah_audio_service.dart';
import 'package:qrn_app/translations.dart';

class GlobalSurahAudioBar extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const GlobalSurahAudioBar({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  static const _primary = Color(0xFF1A5F4A);

  String _t(String key) => Translations.getText(currentLanguage, key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalSurahAudioService>(
      builder: (context, audio, _) {
        if (!audio.showMiniPlayer) return const SizedBox.shrink();

        final bg = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
        final border = isDarkMode
            ? Colors.white12
            : _primary.withValues(alpha: 0.12);

        return Material(
          elevation: 12,
          color: bg,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.graphic_eq_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('quranAudioNowPlaying'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            audio.surahName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1A2E35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _t('audioPrevious'),
                      onPressed: audio.hasPrevious ? () => audio.playPrevious() : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 28,
                        color: audio.hasPrevious
                            ? _primary
                            : Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: audio.isPlaying ? _t('pause') : _t('play'),
                        icon: Icon(
                          audio.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => audio.togglePlayPause(),
                      ),
                    ),
                    IconButton(
                      tooltip: _t('audioNext'),
                      onPressed: audio.hasNext ? () => audio.playNext() : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 28,
                        color: audio.hasNext
                            ? _primary
                            : Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    IconButton(
                      tooltip: _t('audioStop'),
                      onPressed: () => audio.stop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.red[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
