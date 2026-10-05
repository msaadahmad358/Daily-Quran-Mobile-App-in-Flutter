import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qrn_app/services/prayer_notification_service.dart';
import 'package:qrn_app/services/prayer_times_cache.dart';
import 'package:qrn_app/theme/app_surfaces.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/global_surah_audio_bar.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const NotificationsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);
  static const _adhanAsset = 'assets/audio/azan2.mp3';

  final _svc = PrayerNotificationService.instance;
  final _testPlayer = AudioPlayer();

  bool _loading = true;
  bool _master = false;
  Map<String, bool> _prayerOn = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };
  Map<String, String> _schedule = {};
  String _location = '';

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _testPlayer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final master = await _svc.isMasterEnabled();
    final prayers = <String, bool>{};
    for (final p in _prayerOn.keys) {
      prayers[p] = await _svc.isPrayerEnabled(p);
    }
    final schedule = await _svc.scheduledPreview();
    final cache = await PrayerTimesCache.load();
    if (!mounted) return;
    setState(() {
      _master = master;
      _prayerOn = prayers;
      _schedule = schedule;
      _location = cache?.location ?? '';
      _loading = false;
    });
  }

  Future<void> _setMaster(bool v) async {
    if (v) {
      final ok = await _svc.requestPermissionIfNeeded();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('notifPermissionDenied'))),
        );
        return;
      }
    }
    await _svc.setMasterEnabled(v);
    setState(() => _master = v);
    await _load();
  }

  Future<void> _setPrayer(String name, bool v) async {
    await _svc.setPrayerEnabled(name, v);
    setState(() => _prayerOn[name] = v);
  }

  Future<void> _runTest() async {
    final ok = await _svc.requestPermissionIfNeeded();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('notifPermissionDenied'))),
      );
      return;
    }
    final title = _t('notifTestTitle');
    final body = _t('notifTestBody');
    await _svc.showTestNotification(title: title, body: body);
    await _svc.scheduleTestPrayerNotification(
      title: title,
      body: body,
      delay: const Duration(seconds: 15),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('notifScheduledTestHint'))),
      );
    }
    try {
      await _testPlayer.stop();
      await _testPlayer.setAsset(_adhanAsset);
      await _testPlayer.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('notifAdhanPlayError'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = AppSurfaces.card(isDark);

    return Scaffold(
      backgroundColor: AppSurfaces.scaffold(isDark),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _t('notificationsTitle'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      bottomNavigationBar: GlobalSurahAudioBar(
        isDarkMode: isDark,
        currentLanguage: widget.currentLanguage,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: card,
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: const Border(
                          left: BorderSide(color: _primary, width: 5),
                        ),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.mosque_rounded,
                                  color: _primary,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _t('notifHeroTitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1A2E35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _location.isEmpty
                                ? _t('notifNoLocation')
                                : '${_t('notifLocationLabel')}: $_location',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _group(
                    isDark: isDark,
                    card: card,
                    child: SwitchListTile(
                      value: _master,
                      onChanged: _setMaster,
                      activeColor: _primary,
                      title: Text(
                        _t('notifMaster'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A2E35),
                        ),
                      ),
                      subtitle: Text(
                        _t('notifMasterDesc'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t('notifPerPrayer'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _group(
                    isDark: isDark,
                    card: card,
                    child: Column(
                      children: _prayerOn.keys.map((name) {
                        final time = _schedule[name] ?? '--:--';
                        return SwitchListTile(
                          value: _prayerOn[name]! && _master,
                          onChanged: _master
                              ? (v) => _setPrayer(name, v)
                              : null,
                          activeColor: _primary,
                          title: Text(
                            _t(name.toLowerCase()),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1A2E35),
                            ),
                          ),
                          subtitle: Text(
                            '${_t('notifScheduledAt')} $time',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _runTest,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(
                      _t('notifTestButton'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t('notifTestHint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _group({
    required bool isDark,
    required Color card,
    required Widget child,
  }) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(3),
      elevation: isDark ? 0 : 0.5,
      child: child,
    );
  }
}
