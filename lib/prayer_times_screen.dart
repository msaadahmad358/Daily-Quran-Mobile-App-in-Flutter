import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:qrn_app/prayer_period_theme.dart';
import 'package:qrn_app/prayer_city_search_screen.dart';
import 'package:qrn_app/prayer_cities.dart';
import 'package:qrn_app/services/prayer_times_cache.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'translations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'base_screen.dart';
import 'theme/app_surfaces.dart';
import 'services/prayer_notification_service.dart';
import 'navigation/app_navigation.dart';
import 'widgets/app_main_drawer.dart';

class PrayerTimesScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const PrayerTimesScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends BaseScreenState<PrayerTimesScreen> {
  Map<String, dynamic> _prayerTimes = {};
  bool _isRefreshing = false;
  String _errorMessage = '';
  String _selectedCity = 'Paris';
  bool _isUsingLocation = true;
  String _currentCountry = 'France';
  bool _isWeb = false;
  bool _isLocationLoading = false;
  String _displayLocation = '';
  String _hijriDate = '';
  Timer? _tickTimer;
  String _ianaTimezone = 'Europe/Paris';
  bool _initialRefreshDone = false;

  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);

  @override
  void initState() {
    super.initState();
    _isWeb = kIsWeb;
    _displayLocation = _formatLocation(_selectedCity, _currentCountry);
    _applyCache(PrayerTimesCache.peek());
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _bootstrap();
  }

  void _applyCache(PrayerTimesCacheData? cached) {
    if (cached == null) return;
    _prayerTimes = Map<String, dynamic>.from(cached.times);
    if (cached.location.isNotEmpty) {
      _displayLocation = cached.location;
      _syncCityFromDisplay();
    }
    _hijriDate = cached.hijri;
    if (cached.timezone.isNotEmpty) {
      _ianaTimezone = cached.timezone;
    }
  }

  DateTime get _now => _nowInLocation();

  DateTime _nowInLocation() {
    try {
      return tz.TZDateTime.now(tz.getLocation(_ianaTimezone));
    } catch (_) {
      return DateTime.now();
    }
  }

  void _applyTimezoneFromApi(Map<String, dynamic>? meta) {
    if (meta == null) return;
    final id = meta['timezone']?.toString();
    if (id != null && id.isNotEmpty) {
      _ianaTimezone = id;
    }
  }

  String _timezoneFallbackForCountry(String country) {
    final c = country.toLowerCase();
    if (c.contains('france')) return 'Europe/Paris';
    if (c.contains('united kingdom') || c == 'uk') return 'Europe/London';
    if (c.contains('pakistan')) return 'Asia/Karachi';
    if (c.contains('saudi')) return 'Asia/Riyadh';
    if (c.contains('united states')) return 'America/New_York';
    if (c.contains('india')) return 'Asia/Kolkata';
    if (c.contains('turkey')) return 'Europe/Istanbul';
    if (c.contains('egypt')) return 'Africa/Cairo';
    if (c.contains('germany')) return 'Europe/Berlin';
    return 'UTC';
  }

  void _syncCityFromDisplay() {
    final loc = _displayLocation;
    if (loc.isEmpty) return;
    final comma = loc.indexOf(', ');
    if (comma > 0) {
      _selectedCity = loc.substring(0, comma);
      _currentCountry = loc.substring(comma + 2);
    } else {
      _selectedCity = loc;
    }
  }

  String get _locationCity {
    if (_displayLocation.isEmpty) return _selectedCity;
    final comma = _displayLocation.indexOf(', ');
    return comma > 0 ? _displayLocation.substring(0, comma) : _displayLocation;
  }

  String get _locationCountry {
    if (_displayLocation.isEmpty) return _currentCountry;
    final comma = _displayLocation.indexOf(', ');
    return comma > 0 ? _displayLocation.substring(comma + 2) : _currentCountry;
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _persistCache() async {
    if (_prayerTimes.isEmpty) return;
    await PrayerTimesCache.save(
      times: _prayerTimes,
      location: _displayLocation.isNotEmpty
          ? _displayLocation
          : _formatLocation(_selectedCity, _currentCountry),
      hijri: _hijriDate,
      timezone: _ianaTimezone,
    );
    await PrayerNotificationService.instance.rescheduleFromCache();
  }

  String _formatLocation(String city, String country) {
    if (country.isEmpty) return city;
    return '$city, $country';
  }

  void _setManualLocation(String city, String country) {
    _selectedCity = city;
    _currentCountry = country;
    _displayLocation = _formatLocation(city, country);
    _isUsingLocation = false;
  }

  Future<void> _bootstrap() async {
    final cached = await PrayerTimesCache.load();
    if (cached != null && mounted) {
      setState(() {
        _applyCache(cached);
      });
    }
    if (!_initialRefreshDone) {
      _initialRefreshDone = true;
      await _refreshFromDeviceLocation();
    }
  }

  Future<void> _refreshFromDeviceLocation() async {
    setState(() {
      _isRefreshing = _prayerTimes.isNotEmpty;
      _errorMessage = '';
      _isLocationLoading = true;
    });

    // On web, try to get location using browser API
    if (_isWeb) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
        await _applyGpsLocation(position.latitude, position.longitude);
        _finishLocationLoad();
        return;
      } catch (e) {
        // Web location failed, fallback to selected city
        setState(() {
          if (_prayerTimes.isEmpty) {
            _errorMessage =
                'Unable to get location. Using last or default city.';
          }
          _isUsingLocation = false;
          _isLocationLoading = false;
        });
        await _fetchPrayerTimes(city: _selectedCity, country: _currentCountry);
        await _persistCache();
        _finishLocationLoad();
        return;
      }
    }

    // Mobile: Request location permission
    var locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
    }

    if (locationStatus.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
        await _applyGpsLocation(position.latitude, position.longitude);
      } catch (e) {
        setState(() {
          if (_prayerTimes.isEmpty) {
            _errorMessage = 'Unable to get location. Using selected city.';
          }
          _isUsingLocation = false;
        });
        await _fetchPrayerTimes(city: _selectedCity, country: _currentCountry);
        await _persistCache();
      }
    } else {
      setState(() {
        if (_prayerTimes.isEmpty) {
          _errorMessage = 'Location permission denied. Using selected city.';
        }
        _isUsingLocation = false;
      });
      await _fetchPrayerTimes(city: _selectedCity, country: _currentCountry);
      await _persistCache();
    }

    _finishLocationLoad();
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _isLocationLoading = true;
      _isRefreshing = true;
      _isUsingLocation = true;
      _errorMessage = '';
    });
    try {
      final position = await _readCurrentPosition();
      await _applyGpsLocation(position.latitude, position.longitude);
    } catch (e) {
      if (_prayerTimes.isEmpty) {
        setState(() {
          _errorMessage = 'Could not detect location. Try Search City.';
        });
      }
    }
    _finishLocationLoad();
  }

  Future<Position> _readCurrentPosition() async {
    if (!_isWeb) {
      var locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
      }
      if (!locationStatus.isGranted) {
        throw Exception('denied');
      }
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 15),
    );
  }

  Future<void> _applyGpsLocation(double lat, double lon) async {
    setState(() => _isUsingLocation = true);
    await _fetchPrayerTimes(latitude: lat, longitude: lon);
    await _getLocationName(lat, lon);
    await _persistCache();
  }

  void _finishLocationLoad() {
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      _isLocationLoading = false;
    });
  }

  Future<void> _getLocationName(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10';
      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'User-Agent': 'DailyQuranMobile/1.0 (prayer-times)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address != null) {
          final city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              address['state'];
          final country = address['country']?.toString() ?? '';
          if (city != null) {
            setState(() {
              _selectedCity = city.toString();
              _currentCountry = country;
              _displayLocation = _formatLocation(_selectedCity, _currentCountry);
            });
          } else if (country.isNotEmpty) {
            setState(() {
              _currentCountry = country;
              _displayLocation = _formatLocation(_selectedCity, country);
            });
          }
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _fetchPrayerTimes({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
  }) async {
    try {
      String url;
      if (latitude != null && longitude != null) {
        url =
            'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2';
      } else {
        final c = city ?? _selectedCity;
        final co = country ??
            (_currentCountry.isNotEmpty
                ? _currentCountry
                : prayerCityEntry(c)['country'] ?? '');
        url =
            'https://api.aladhan.com/v1/timingsByCity?city=${Uri.encodeComponent(c)}&country=${Uri.encodeComponent(co)}&method=2';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final timings = data['data']['timings'];
          final date = data['data']['date']['readable'];
          final hijri = data['data']['date']['hijri'];
          final meta = data['data']['meta'] as Map<String, dynamic>?;
          var hijriLine = '';
          if (hijri is Map) {
            hijriLine =
                '${hijri['day']} ${hijri['month']?['en'] ?? ''} ${hijri['year']} H';
          }

          setState(() {
            _applyTimezoneFromApi(meta);
            if (_ianaTimezone == 'Europe/Paris' &&
                _currentCountry.isNotEmpty &&
                meta?['timezone'] == null) {
              _ianaTimezone = _timezoneFallbackForCountry(_currentCountry);
            }
            _prayerTimes = {
              'date': date,
              'Fajr': timings['Fajr'],
              'Sunrise': timings['Sunrise'],
              'Dhuhr': timings['Dhuhr'],
              'Asr': timings['Asr'],
              'Maghrib': timings['Maghrib'],
              'Isha': timings['Isha'],
            };
            _hijriDate = hijriLine;
            if (_displayLocation.isEmpty) {
              _displayLocation =
                  _formatLocation(_selectedCity, _currentCountry);
            }
            _errorMessage = '';
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to fetch prayer times. Please try again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Network error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  DateTime? _timeOnDay(String? raw, DateTime day) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split(':');
      if (parts.length < 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1].split(' ')[0]);
      return DateTime(day.year, day.month, day.day, h, m);
    } catch (_) {
      return null;
    }
  }

  DateTime? _nextPrayerDateTime() {
    const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final key in order) {
      final t = _timeOnDay(_prayerTimes[key]?.toString(), _now);
      if (t != null && t.isAfter(_now)) return t;
    }
    final tomorrow = _now.add(const Duration(days: 1));
    return _timeOnDay(_prayerTimes['Fajr']?.toString(), tomorrow);
  }

  String _formatCountdown(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  String _currentClock() {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _currentClockWithSeconds() {
    return DateFormat('h:mm:ss a').format(_now);
  }

  Future<void> _applyCitySelection(String city, String country) async {
    setState(() {
      _setManualLocation(city, country);
      _ianaTimezone = _timezoneFallbackForCountry(country);
      _isRefreshing = true;
      _errorMessage = '';
    });
    await _fetchPrayerTimes(city: city, country: country);
    await _persistCache();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _openCitySearch() async {
    final picked = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => PrayerCitySearchScreen(isDarkMode: widget.isDarkMode),
      ),
    );
    if (picked == null || !mounted) return;
    await _applyCitySelection(
      picked['city'] ?? '',
      picked['country'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: AppSurfaces.scaffold(isDark),
      drawer: const AppMainDrawer(),
      appBar: _buildPrayerAppBar(getText),
      body: _buildPrayerHome(isDark, getText),
    );
  }

  PreferredSizeWidget _buildPrayerAppBar(String Function(String) getText) {
    final city = _isLocationLoading ? 'Updating…' : _locationCity;
    final country = _locationCountry;

    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 0.2,
            ),
          ),
          if (country.isNotEmpty)
            Text(
              country,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => openAppNotifications(context),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildPrayerHome(bool isDark, String Function(String) getText) {
    final period = PrayerPeriodTheme.periodForNow(_prayerTimes, _now);
    final bgAsset = PrayerPeriodTheme.assetPaths[period]!;
    final nextKey = _getNextPrayer();
    final nextLabel = getText(nextKey.toLowerCase());
    final nextAt = _nextPrayerDateTime();
    final countdown = nextAt != null
        ? _formatCountdown(nextAt.difference(_now))
        : '--:--';
    return Column(
      children: [
        _buildHeroHeader(
          bgAsset: bgAsset,
          clock: _currentClock(),
          clockDetail: _currentClockWithSeconds(),
          nextLabel: nextLabel,
          countdown: countdown,
          gregorianDate: _prayerTimes['date']?.toString() ?? '',
          hijriDate: _hijriDate,
        ),
        _buildLocationActions(isDark, getText),
        if (_isRefreshing)
          LinearProgressIndicator(
            minHeight: 2,
            color: _primary,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE8E8E8),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          getText('prayerTimes'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          'Time',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map(
                  (prayer) => _buildPrayerRow(
                    isDark: isDark,
                    prayerKey: prayer,
                    name: getText(prayer.toLowerCase()),
                    time: _prayerTimes[prayer]?.toString() ?? '--:--',
                    isNext: prayer == nextKey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader({
    required String bgAsset,
    required String clock,
    required String clockDetail,
    required String nextLabel,
    required String countdown,
    required String gregorianDate,
    required String hijriDate,
  }) {
    return SizedBox(
      height: 188,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bgAsset, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                Text(
                  clock,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  clockDetail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$nextLabel in $countdown',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chevron_left, color: Colors.grey.shade400),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              gregorianDate,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (hijriDate.isNotEmpty)
                              Text(
                                hijriDate,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationActions(bool isDark, String Function(String) getText) {
    const btnHeight = 48.0;
    ButtonStyle btnStyle(bool selected) => OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 1.2),
          minimumSize: const Size.fromHeight(btnHeight),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLocationLoading ? null : _useMyLocation,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text('My Location'),
              style: btnStyle(false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openCitySearch,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Search City'),
              style: btnStyle(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow({
    required bool isDark,
    required String prayerKey,
    required String name,
    required String time,
    required bool isNext,
  }) {
    final divider = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isNext ? _primary.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(12),
            border: isNext
                ? Border.all(color: _primary.withValues(alpha: 0.45), width: 1.5)
                : Border(bottom: BorderSide(color: divider)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isNext
                      ? _primary.withValues(alpha: 0.18)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPrayerIcon(prayerKey),
                  color: isNext
                      ? _primary
                      : (isDark ? Colors.white70 : Colors.black87),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                        color: isNext
                            ? _primary
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    if (isNext)
                      Text(
                        'Next prayer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primary.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  time,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isNext
                        ? _primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextPrayer() {
    const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final key in order) {
      final t = _timeOnDay(_prayerTimes[key]?.toString(), _now);
      if (t != null && t.isAfter(_now)) return key;
    }
    return 'Fajr';
  }

  IconData _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nightlight_round;
      case 'isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}
