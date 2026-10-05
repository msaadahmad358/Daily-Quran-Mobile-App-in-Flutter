import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/global_surah_audio_bar.dart';

const Color _kPrimary = Color(0xFF1A5F4A);
const Color _kOrange = Color(0xFFFF8A1E);
const String _kKaaba = 'assets/images/qibla/kaaba_clear.png';
const String _kDial = 'assets/images/qibla/qibla_compass_dial.png';
const LatLng _mecca = LatLng(21.4225, 39.8262);

double _qiblaBearing(double lat, double lng) {
  const kLat = 21.4225 * math.pi / 180;
  const kLng = 39.8262 * math.pi / 180;
  final lat1 = lat * math.pi / 180;
  final dLng = kLng - lng * math.pi / 180;
  final y = math.sin(dLng) * math.cos(kLat);
  final x = math.cos(lat1) * math.sin(kLat) -
      math.sin(lat1) * math.cos(kLat) * math.cos(dLng);
  var brng = math.atan2(y, x) * 180 / math.pi;
  return (brng + 360) % 360;
}

class QiblaPage extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const QiblaPage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  final _map = MapController();
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<MagnetometerEvent>? _magnetSub;
  double _heading = 0;
  bool _fitted = false;
  LatLng _user = const LatLng(31.5497, 74.3436);
  bool _locating = true;

  String _t(String key) =>
      Translations.getText(widget.currentLanguage, key);

  @override
  void initState() {
    super.initState();
    _listenCompass();
    _loadLocation();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _magnetSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      var locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
      }
      if (!locationStatus.isGranted) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.deniedForever) {
          await openAppSettings();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          if (mounted) setState(() => _locating = false);
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
      if (!mounted) return;
      setState(() {
        _user = LatLng(pos.latitude, pos.longitude);
        _locating = false;
        _fitted = false;
      });
    } catch (_) {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _listenCompass() {
    try {
      final stream = FlutterCompass.events;
      if (stream == null) {
        _listenMagnetometer();
        return;
      }
      _compassSub = stream.listen(
        (event) {
          final h = event.heading;
          if (!mounted || h == null) return;
          setState(() => _heading = h);
        },
        onError: (_) => _listenMagnetometer(),
        cancelOnError: true,
      );
    } catch (_) {
      _listenMagnetometer();
    }
  }

  void _listenMagnetometer() {
    if (_magnetSub != null) return;
    try {
      _magnetSub = magnetometerEventStream().listen((event) {
        if (!mounted) return;
        var h = math.atan2(event.y, event.x) * 180 / math.pi;
        h = (h + 360) % 360;
        setState(() => _heading = h);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final user = _user;
    final qibla = _qiblaBearing(user.latitude, user.longitude);
    final km = Geolocator.distanceBetween(
          user.latitude,
          user.longitude,
          _mecca.latitude,
          _mecca.longitude,
        ) /
        1000;

    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('qibla'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: GlobalSurahAudioBar(
        isDarkMode: isDark,
        currentLanguage: widget.currentLanguage,
      ),
      body: _locating
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _DistanceCard(
                    km: km,
                    isDark: isDark,
                    label: _t('distanceToMakkah'),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: LatLng(
                            (user.latitude + _mecca.latitude) / 2,
                            (user.longitude + _mecca.longitude) / 2,
                          ),
                          initialZoom: 3.4,
                          onMapReady: () {
                            if (_fitted) return;
                            _fitted = true;
                            _map.fitCamera(
                              CameraFit.coordinates(
                                coordinates: [user, _mecca],
                                padding: const EdgeInsets.all(40),
                                maxZoom: 5.5,
                              ),
                            );
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.qrnapp.dailyquran',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [user, _mecca],
                                color: _kPrimary,
                                strokeWidth: 2.4,
                                pattern: StrokePattern.dashed(
                                  segments: const [10, 8],
                                ),
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: user,
                                width: 36,
                                height: 36,
                                alignment: Alignment.bottomCenter,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: _kPrimary,
                                  size: 36,
                                ),
                              ),
                              Marker(
                                point: _mecca,
                                width: 34,
                                height: 34,
                                child: Image.asset(
                                  _kKaaba,
                                  width: 30,
                                  height: 30,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.mosque_rounded,
                                    color: _kPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _QiblaCompass(heading: _heading, qibla: qibla),
                ),
              ],
            ),
    );
  }
}

class _DistanceCard extends StatelessWidget {
  final double km;
  final bool isDark;
  final String label;

  const _DistanceCard({
    required this.km,
    required this.isDark,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            _kKaaba,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.mosque_rounded,
              color: _kPrimary,
              size: 40,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : const Color(0xFF9AA4A8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${km.round()} km',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final double heading;
  final double qibla;

  const _QiblaCompass({required this.heading, required this.qibla});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth, c.maxHeight) - 12;
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -heading * math.pi / 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          _kDial,
                          width: size,
                          height: size,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      Transform.rotate(
                        angle: qibla * math.pi / 180,
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: Align(
                            alignment: const Alignment(0, -0.92),
                            child: Image.asset(
                              _kKaaba,
                              width: size * 0.09,
                              height: size * 0.09,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.mosque_rounded,
                                color: _kPrimary,
                                size: size * 0.08,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: Size(size * 0.16, size * 0.16),
                  painter: _NeedlePainter(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final path = ui.Path()
      ..moveTo(c.dx, c.dy - size.height * 0.46)
      ..lineTo(c.dx - size.width * 0.28, c.dy + size.height * 0.22)
      ..lineTo(c.dx + size.width * 0.28, c.dy + size.height * 0.22)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = _kOrange
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
