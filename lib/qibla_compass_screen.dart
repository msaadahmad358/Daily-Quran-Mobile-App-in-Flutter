import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

class QiblaCompassScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const QiblaCompassScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  double _heading = 0.0;
  double _qiblaAngle = 0.0;
  bool _hasSensor = false;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasLocation = false;

  // Mecca coordinates
  final double _meccaLat = 21.4225;
  final double _meccaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    // Request permissions
    final sensorStatus = await Permission.sensors.request();
    final locationStatus = await Permission.location.request();

    if (sensorStatus.isGranted) {
      _listenToSensors();
    } else {
      setState(() {
        _errorMessage = 'Sensor permission required for compass';
        _isLoading = false;
      });
    }

    if (locationStatus.isGranted) {
      await _getUserLocation();
    } else {
      setState(() {
        _errorMessage = 'Location permission required for Qibla direction';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      _calculateQibla(position.latitude, position.longitude);
      setState(() {
        _hasLocation = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to get location. Using approximate direction.';
        _isLoading = false;
        // Fallback: use default Qibla angle
        _qiblaAngle = 295.0;
      });
    }
  }

  void _calculateQibla(double lat, double lon) {
    // Haversine formula to calculate Qibla direction
    double lat1 = lat * pi / 180;
    double lon1 = lon * pi / 180;
    double lat2 = _meccaLat * pi / 180;
    double lon2 = _meccaLon * pi / 180;

    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = atan2(y, x) * 180 / pi;
    _qiblaAngle = (bearing + 360) % 360;
  }

  void _listenToSensors() {
    try {
      // Listen to magnetometer for compass heading
      magnetometerEvents.listen((MagnetometerEvent event) {
        // Calculate heading from magnetometer data
        double heading = atan2(event.y, event.x) * 180 / pi;
        heading = (heading + 360) % 360;
        setState(() {
          _heading = heading;
          _hasSensor = true;
        });
      });
    } catch (e) {
      setState(() {
        _hasSensor = false;
        _errorMessage = 'Compass not available. Using fallback.';
        _isLoading = false;
      });
      _simulateCompass();
    }
  }

  void _simulateCompass() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _heading = (_heading + 0.5) % 360;
        });
        _simulateCompass();
      }
    });
  }

  double _getAngleDifference(double heading, double target) {
    double diff = target - heading;
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        AppTranslations.getText(widget.currentLanguage, key);

    final diff = _getAngleDifference(_heading, _qiblaAngle);
    final isFacingQibla = diff.abs() < 15;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing compass...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(
          getText('qibla'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isFacingQibla
                    ? Colors.green.withValues(alpha: 0.15)
                    : const Color(0xFFC9A96E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFacingQibla ? Colors.green : const Color(0xFFC9A96E),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFacingQibla ? Icons.check_circle : Icons.rotate_right,
                    color: isFacingQibla
                        ? Colors.green
                        : const Color(0xFFC9A96E),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isFacingQibla
                        ? '🕋 You are facing Qibla!'
                        : '🔄 Rotate your device',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isFacingQibla
                          ? Colors.green
                          : const Color(0xFFC9A96E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Compass
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                      : [Colors.white, const Color(0xFFF8F5F0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                  ),

                  // Direction markers
                  ...['N', 'E', 'S', 'W'].asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    final angle = index * 90.0;
                    final radians = angle * pi / 180;
                    final radius = 130.0;
                    final x = radius * sin(radians);
                    final y = -radius * cos(radians);
                    final isNorth = label == 'N';

                    return Positioned(
                      left: 160 + x - 16,
                      top: 160 + y - 16,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: isNorth ? 22 : 18,
                            fontWeight: isNorth
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: isNorth
                                ? const Color(0xFFE74C3C)
                                : (isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[600]!),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Compass needle
                  Transform.rotate(
                    angle: -_heading * pi / 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // North pointer
                        Container(
                          width: 4,
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFE74C3C), Colors.transparent],
                            ),
                          ),
                        ),
                        // South pointer
                        Container(
                          width: 4,
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.grey, Colors.transparent],
                            ),
                          ),
                        ),
                        // North arrow head
                        Positioned(
                          top: 8,
                          child: Transform.rotate(
                            angle: -45 * pi / 180,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE74C3C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Qibla arrow
                  Transform.rotate(
                    angle: (_qiblaAngle - _heading) * pi / 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 140,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFC9A96E), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Color(0xFFC9A96E),
                            size: 32,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A96E),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFC9A96E,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Qibla',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    getText('qiblaDirection'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_qiblaAngle.toStringAsFixed(1)}° • ${isFacingQibla ? "✅ Correct" : "↻ Rotate to align"}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isFacingQibla
                          ? Colors.green
                          : const Color(0xFFC9A96E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Sensor status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[800] : Colors.grey[200])
                    ?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasSensor ? Icons.sensors : Icons.sensors_off,
                    size: 16,
                    color: _hasSensor ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hasSensor ? 'Live compass' : 'Simulated',
                    style: TextStyle(
                      fontSize: 12,
                      color: _hasSensor ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
