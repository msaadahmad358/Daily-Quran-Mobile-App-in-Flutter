import 'package:flutter/material.dart';

class QuranAyahCard extends StatelessWidget {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC5A059);
  static const _translationTeal = Color(0xFF003D4C);
  static const _iconGrey = Color(0xFF8A8A8A);
  static const _divider = Color(0xFFE0E0E0);

  final int ayahNumber;
  final String arabic;
  final String translation;
  final bool isDark;
  final bool isFavorite;
  final bool isPlaying;
  final double arabicFontSize;
  final String arabicFontFamily;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;
  final VoidCallback onPlay;
  final VoidCallback onShare;

  const QuranAyahCard({
    super.key,
    required this.ayahNumber,
    required this.arabic,
    required this.translation,
    required this.isDark,
    required this.isFavorite,
    this.isPlaying = false,
    this.arabicFontSize = 26,
    this.arabicFontFamily = 'IndoPak',
    required this.onCopy,
    required this.onFavorite,
    required this.onPlay,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.grey.shade400 : _iconGrey;
    final dividerColor = isDark ? Colors.white12 : _divider;
    final playColor = isDark ? _primary : const Color(0xFF00695C);
    final highlight = isPlaying
        ? (isDark
            ? _primary.withValues(alpha: 0.22)
            : _primary.withValues(alpha: 0.1))
        : cardColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: highlight,
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 1),
          left: isPlaying
              ? const BorderSide(color: _primary, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      arabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: arabicFontFamily,
                        fontSize: arabicFontSize,
                        height: 1.85,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (translation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    translation,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? Colors.grey.shade300 : _translationTeal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Row(
              children: [
                _PlayCircleButton(
                  color: playColor,
                  isPlaying: isPlaying,
                  onTap: onPlay,
                ),
                const SizedBox(width: 4),
                _AyahActionIcon(
                  icon: Icons.share_outlined,
                  color: iconColor,
                  onTap: onShare,
                ),
                _AyahActionIcon(
                  icon: Icons.copy_all_outlined,
                  color: iconColor,
                  onTap: onCopy,
                ),
                _AyahActionIcon(
                  icon: isFavorite ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: isFavorite ? _primary : iconColor,
                  onTap: onFavorite,
                ),
                const Spacer(),
                _OctagonAyahBadge(number: ayahNumber, color: _gold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final Color color;
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayCircleButton({
    required this.color,
    this.isPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _AyahActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AyahActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _OctagonAyahBadge extends StatelessWidget {
  final int number;
  final Color color;

  const _OctagonAyahBadge({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 21,
      height: 21,
      child: CustomPaint(
        painter: _OctagonPainter(color: color),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _OctagonPainter extends CustomPainter {
  final Color color;

  _OctagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final w = size.width;
    final h = size.height;
    const cut = 3.5;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OctagonPainter oldDelegate) =>
      oldDelegate.color != color;
}
