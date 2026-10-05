import 'package:flutter/material.dart';

/// Home/More icons (PNG mattes removed in assets for dark mode).
class ThemedAssetIcon extends StatelessWidget {
  const ThemedAssetIcon({
    super.key,
    required this.asset,
    required this.isDark,
    this.size = 52,
    this.surfaceColor,
    this.errorIconSize = 34,
  });

  final String asset;
  final bool isDark;
  final double size;
  final Color? surfaceColor;
  final double errorIconSize;

  static const _primary = Color(0xFF1A5F4A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_outlined,
          size: errorIconSize,
          color: isDark ? Colors.white70 : _primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
