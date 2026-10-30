import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'translations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'base_screen.dart';

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

class _QiblaCompassScreenState extends BaseScreenState<QiblaCompassScreen>
    with TickerProviderStateMixin {
  double _heading = 0.0;
  double _qiblaAngle = 295.0;
  double _distanceToQibla = 0.0;
  double _smoothHeading = 0.0;
  bool _hasSensor = false;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasLocation = false;
  bool _hasPermissions = false;
  String _locationName = 'Unknown';
  bool _isSimulating = false;
  bool _isListening = false;
  bool _isManualControl = false;
  double _manualHeading = 0.0;
  bool _isWeb = false;

  // Mecca coordinates
  final double _meccaLat = 21.4225;
  final double _meccaLon = 39.8262;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check if running on web
    _isWeb = kIsWeb;

    _initializeCompass();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _isListening = false;
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isManualControl = false;
    });

    try {
      // Check if running on web
      if (_isWeb) {
        setState(() {
          _isManualControl = true;
          _isSimulating = true;
          _hasSensor = false;
          _errorMessage = '🌐 Web mode: Use slider to rotate compass';
        });
        await _getUserLocationWeb();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Request permissions for mobile
      await _requestPermissions();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e. Using manual control.';
        _isManualControl = true;
        _isSimulating = true;
        _isLoading = false;
      });
      await _getUserLocation();
    }
  }

  // Web-specific location method
  Future<void> _getUserLocationWeb() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      _calculateQibla(position.latitude, position.longitude);
      _calculateDistance(position.latitude, position.longitude);
      await _getLocationName(position.latitude, position.longitude);

      setState(() {
        _hasLocation = true;
        _isLoading = false;
        _errorMessage =
            '🌐 Web mode: Location detected! Use slider to rotate compass.';
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            '🌐 Web: Unable to get location. Using default Qibla angle.';
        _hasLocation = false;
        _isLoading = false;
        _qiblaAngle = 295.0;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request location permission (use locationWhenInUse for iOS/Android)
      var locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
      }

      // Request sensor permission (iOS specific)
      PermissionStatus sensorStatus = PermissionStatus.granted;
      if (Platform.isIOS) {
        try {
          sensorStatus = await Permission.sensors.request();
        } catch (_) {
          // Simulators or certain devices may throw or fail for sensors
          sensorStatus = PermissionStatus.granted;
        }
      } else {
        // On Android, sensors permission is not required separately
        sensorStatus = PermissionStatus.granted;
      }

      // If location is granted, allow location functionality even if simulator lacks sensors
      if (locationStatus.isGranted) {
        setState(() {
          _hasPermissions = true;
          if (!sensorStatus.isGranted) {
            _isManualControl = true;
            _isSimulating = true;
          }
        });
        await _getUserLocation();
        if (sensorStatus.isGranted) {
          _listenToSensors();
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        // One or both permissions denied
        setState(() {
          _hasPermissions = false;
          _isManualControl = true;
          _isSimulating = true;
          _isLoading = false;
        });

        // Show permission dialog
        _showPermissionDialog(
          locationGranted: locationStatus.isGranted,
          sensorGranted: sensorStatus.isGranted,
        );

        // Try to get location anyway if location is granted
        if (locationStatus.isGranted) {
          await _getUserLocation();
        } else {
          setState(() {
            _qiblaAngle = 295.0;
            _errorMessage =
                'Location permission denied. Using default Qibla angle.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Permission error: $e';
        _isManualControl = true;
        _isSimulating = true;
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog({
    required bool locationGranted,
    required bool sensorGranted,
  }) {
    String message = '';
    if (!locationGranted && !sensorGranted) {
      message =
          'This app needs location and sensor permissions to show accurate Qibla direction.\n\nYou can still use the manual slider to test the Qibla direction.';
    } else if (!locationGranted) {
      message =
          'This app needs location permission to calculate accurate Qibla direction.\n\nYou can still use the manual slider with a default Qibla angle.';
    } else if (!sensorGranted) {
      message =
          'This app needs sensor permission for the compass.\n\nYou can still use the manual slider to test the Qibla direction.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text(getText('permissionsRequired')),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isManualControl = true;
                _isSimulating = true;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A5F4A),
            ),
            child: Text(getText('useManualSlider')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeCompass();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _getUserLocation() async {
    try {
      // Check if location permission is granted
      var locationStatus = await Permission.locationWhenInUse.status;
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.status;
      }
      if (!locationStatus.isGranted) {
        setState(() {
          _errorMessage =
              'Location permission denied. Using default Qibla angle.';
          _qiblaAngle = 295.0;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      _calculateQibla(position.latitude, position.longitude);
      _calculateDistance(position.latitude, position.longitude);
      await _getLocationName(position.latitude, position.longitude);

      setState(() {
        _hasLocation = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to get location. Using default Qibla angle.';
        _hasLocation = false;
        _isLoading = false;
        _qiblaAngle = 295.0;
      });
    }
  }

  Future<void> _getLocationName(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address != null) {
          final city =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state'] ??
              address['country'];
          final country = address['country'] ?? '';
          setState(() {
            _locationName = city != null ? '$city, $country' : country;
          });
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  void _calculateQibla(double lat, double lon) {
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

  void _calculateDistance(double lat, double lon) {
    double lat1 = lat * pi / 180;
    double lon1 = lon * pi / 180;
    double lat2 = _meccaLat * pi / 180;
    double lon2 = _meccaLon * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double radius = 6371.0;

    _distanceToQibla = radius * c;
  }

  void _listenToSensors() {
    if (_isListening) return;
    _isListening = true;

    try {
      magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          if (!mounted) return;
          if (_isManualControl) return;

          double heading = atan2(event.y, event.x) * 180 / pi;
          heading = (heading + 360) % 360;

          double diff = heading - _smoothHeading;
          if (diff > 180) diff -= 360;
          if (diff < -180) diff += 360;
          _smoothHeading += diff * 0.15;
          _smoothHeading = (_smoothHeading + 360) % 360;

          setState(() {
            _heading = heading;
            _smoothHeading = _smoothHeading;
            _hasSensor = true;
            _isSimulating = false;
          });
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _hasSensor = false;
              _errorMessage = 'Compass sensor error. Using manual slider.';
              _isSimulating = true;
              _isManualControl = true;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _hasSensor = false;
        _errorMessage = 'Compass not available. Using manual slider.';
        _isLoading = false;
        _isSimulating = true;
        _isManualControl = true;
      });
    }
  }

  double _getAngleDifference(double heading, double target) {
    double diff = target - heading;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    final currentHeading = _isManualControl ? _manualHeading : _smoothHeading;
    final diff = _getAngleDifference(currentHeading, _qiblaAngle);
    final isFacingQibla = diff.abs() < 15;
    final isNearQibla = diff.abs() < 30;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(
          '🕋 ${getText('qibla')}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF1A5F4A),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _initializeCompass,
          ),
          if (!_isWeb)
            // ===== UPDATED: Added icon to switch button =====
            GestureDetector(
              onTap: () {
                setState(() {
                  _isManualControl = !_isManualControl;
                  if (_isManualControl) {
                    _isSimulating = true;
                    _errorMessage = '🖐️ Manual control mode';
                  } else {
                    _isSimulating = false;
                    _errorMessage = '';
                    _listenToSensors();
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: _isManualControl
                      ? const LinearGradient(
                          colors: [Colors.orange, Color(0xFFE67E22)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isManualControl
                                  ? Colors.orange
                                  : const Color(0xFF1A5F4A))
                              .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isManualControl
                          ? Icons.record_voice_over_rounded
                          : Icons.sensors_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isManualControl ? getText('manual') : getText('sensor'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A5F4A),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    getText('initializingCompass'),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Web Permission Notice
                      if (_isWeb)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  getText('webChromeAllow'),

                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Location
                      if (_locationName != 'Unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _hasLocation ? Icons.gps_fixed : Icons.gps_off,
                                color: _hasLocation
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _locationName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_isManualControl) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '🖐️ Manual',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Status Badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isFacingQibla
                              ? const LinearGradient(
                                  colors: [Colors.green, Color(0xFF27AE60)],
                                )
                              : isNearQibla
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFC9A96E),
                                    Color(0xFFF39C12),
                                  ],
                                )
                              : LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF2A2A2A),
                                          const Color(0xFF1E1E1E),
                                        ]
                                      : [Colors.grey[300]!, Colors.grey[200]!],
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isFacingQibla
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : isNearQibla
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC9A96E,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFacingQibla
                                  ? Icons.check_circle
                                  : isNearQibla
                                  ? Icons.trending_up
                                  : Icons.rotate_right,
                              color: isFacingQibla
                                  ? Colors.white
                                  : isNearQibla
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isFacingQibla
                                  ? getText('facingQibla')
                                  : isNearQibla
                                  ? getText('almostThere')
                                  : getText('rotateDevice'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: (isFacingQibla || isNearQibla)
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ========== COMPASS ==========
                      Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF1A1A1A),
                                    const Color(0xFF2A2A2A),
                                  ]
                                : [Colors.white, const Color(0xFFF8F5F0)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer decorative ring
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3D3D3D)
                                      : const Color(0xFFE8E0D8),
                                  width: 2,
                                ),
                              ),
                            ),

                            // Inner decorative ring
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF0EDE8),
                                  width: 1,
                                ),
                              ),
                            ),

                            // Compass rose
                            ..._buildCompassRose(isDark),

                            // Qibla arc indicator
                            _buildQiblaArc(isDark, diff),

                            // Needle container (rotates)
                            Transform.rotate(
                              angle: -currentHeading * pi / 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // North needle
                                  Container(
                                    width: 3,
                                    height: 130,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFE74C3C),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // South needle
                                  Container(
                                    width: 3,
                                    height: 130,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.grey,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // North arrow head
                                  Positioned(
                                    top: 4,
                                    child: CustomPaint(
                                      painter: ArrowPainter(
                                        color: const Color(0xFFE74C3C),
                                        isNorth: true,
                                      ),
                                      size: const Size(28, 28),
                                    ),
                                  ),
                                  // South arrow head
                                  Positioned(
                                    bottom: 4,
                                    child: CustomPaint(
                                      painter: ArrowPainter(
                                        color: Colors.grey,
                                        isNorth: false,
                                      ),
                                      size: const Size(20, 20),
                                    ),
                                  ),
                                  // Center dot
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE74C3C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Qibla pointer (fixed direction)
                            Transform.rotate(
                              angle: (_qiblaAngle) * pi / 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Qibla line
                                  Container(
                                    width: 3,
                                    height: 160,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFC9A96E),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Qibla arrow head
                                  Positioned(
                                    top: 2,
                                    child: CustomPaint(
                                      painter: QiblaArrowPainter(
                                        color: const Color(0xFFC9A96E),
                                      ),
                                      size: const Size(32, 32),
                                    ),
                                  ),
                                  // Qibla label
                                  Positioned(
                                    bottom: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC9A96E),
                                            Color(0xFFD4A84A),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFC9A96E,
                                            ).withValues(alpha: 0.4),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        getText('qiblaLabel'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Glow effect when facing Qibla
                            if (isFacingQibla)
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ========== MANUAL CONTROL SLIDER ==========
                      if (_isManualControl) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E1E1E),
                                      const Color(0xFF2A2A2A),
                                    ]
                                  : [Colors.white, const Color(0xFFF8F5F0)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.rotate_left,
                                        color: const Color(0xFF1A5F4A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        getText('rotateCompass'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_manualHeading.toStringAsFixed(0)}°',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Slider(
                                value: _manualHeading,
                                min: 0,
                                max: 360,
                                divisions: 360,
                                label: '${_manualHeading.toStringAsFixed(0)}°',
                                onChanged: (value) {
                                  setState(() {
                                    _manualHeading = value;
                                  });
                                },
                                activeColor: const Color(0xFF1A5F4A),
                                inactiveColor: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                thumbColor: const Color(0xFFC9A96E),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildQuickRotateButton(
                                    icon: Icons.rotate_left,
                                    label: '90°',
                                    onTap: () {
                                      setState(() {
                                        _manualHeading =
                                            (_manualHeading - 90) % 360;
                                        if (_manualHeading < 0) {
                                          _manualHeading += 360;
                                        }
                                      });
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickRotateButton(
                                    icon: Icons.rotate_right,
                                    label: '90°',
                                    onTap: () {
                                      setState(() {
                                        _manualHeading =
                                            (_manualHeading + 90) % 360;
                                      });
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickRotateButton(
                                    icon: Icons.refresh,
                                    label: 'Reset',
                                    onTap: () {
                                      setState(() {
                                        _manualHeading = 0;
                                      });
                                    },
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildQuickRotateButton(
                                    icon: Icons.arrow_upward,
                                    label: 'Qibla',
                                    onTap: () {
                                      setState(() {
                                        _manualHeading = _qiblaAngle;
                                      });
                                    },
                                    isDark: isDark,
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ========== INFO CARDS ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoCard(
                            isDark: isDark,
                            icon: Icons.straighten,
                            label: getText('qiblaAngle'),
                            value: '${_qiblaAngle.toStringAsFixed(1)}°',
                            color: const Color(0xFFC9A96E),
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            isDark: isDark,
                            icon: Icons.location_on,
                            label: getText('distanceToQibla'),
                            value: _distanceToQibla > 0
                                ? '${_distanceToQibla.toStringAsFixed(0)} ${getText('km')}'
                                : '--',
                            color: const Color(0xFF2E86C1),
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            isDark: isDark,
                            icon: Icons.arrow_upward,
                            label: getText('accuracy'),
                            value: '${diff.abs().toStringAsFixed(1)}°',
                            color: isFacingQibla
                                ? Colors.green
                                : isNearQibla
                                ? const Color(0xFFC9A96E)
                                : Colors.grey,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ========== SENSOR STATUS ==========
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.grey[800] : Colors.grey[200])
                              ?.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isManualControl
                                    ? Colors.orange
                                    : (_hasSensor
                                          ? Colors.green
                                          : Colors.orange),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isManualControl
                                  ? getText('manualControl')
                                  : (_hasSensor
                                        ? getText('liveCompass')
                                        : _isSimulating
                                        ? getText('simulated')
                                        : getText('noSensor')),
                              style: TextStyle(
                                fontSize: 12,
                                color: _isManualControl
                                    ? Colors.orange
                                    : (_hasSensor
                                          ? Colors.green
                                          : Colors.orange),
                                fontWeight: FontWeight.w500,
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
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[700],
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ========== PERMISSION STATUS (iOS/Android) ==========
                      if (!_isWeb && !_hasPermissions)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.red[300],
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  Platform.isIOS
                                      ? 'Permissions required. Go to Settings > Privacy > Location & Motion to enable.'
                                      : 'Permissions required. Tap Retry to grant permissions.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[300],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (Platform.isIOS) {
                                    // Open app settings on iOS
                                    openAppSettings();
                                  } else {
                                    _initializeCompass();
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A5F4A),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  Platform.isIOS
                                      ? getText('openSettings')
                                      : getText('retry'),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ========== WEB LOCATION STATUS ==========
                      if (_isWeb && !_hasLocation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  getText('webChromeAllow'),

                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _initializeCompass,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1A5F4A),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildQuickRotateButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFC9A96E), Color(0xFFD4A84A)],
                )
              : LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
                      : [Colors.grey[200]!, Colors.grey[100]!],
                ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFFC9A96E).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCompassRose(bool isDark) {
    final directions = [
      {'label': 'N', 'angle': 0.0, 'isNorth': true},
      {'label': 'E', 'angle': 90.0, 'isNorth': false},
      {'label': 'S', 'angle': 180.0, 'isNorth': false},
      {'label': 'W', 'angle': 270.0, 'isNorth': false},
    ];

    return directions.map((dir) {
      final angle = (dir['angle'] as num).toDouble();
      final radians = angle * pi / 180;
      final radius = 135.0;
      final x = radius * sin(radians);
      final y = -radius * cos(radians);
      final isNorth = dir['isNorth'] as bool;

      return Positioned(
        left: 170 + x - 20,
        top: 170 + y - 20,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            dir['label'] as String,
            style: TextStyle(
              fontSize: isNorth ? 24 : 18,
              fontWeight: isNorth ? FontWeight.bold : FontWeight.w400,
              color: isNorth
                  ? const Color(0xFFE74C3C)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              letterSpacing: isNorth ? 1 : 0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQiblaArc(bool isDark, double diff) {
    final isFacing = diff.abs() < 15;
    final arcColor = isFacing
        ? Colors.green
        : diff.abs() < 30
        ? const Color(0xFFC9A96E)
        : isDark
        ? Colors.grey[600]
        : Colors.grey[300];

    return Positioned(
      child: CustomPaint(
        size: const Size(280, 280),
        painter: ArcPainter(color: arcColor!, diff: diff, isDark: isDark),
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ CUSTOM PAINTERS ============

class ArrowPainter extends CustomPainter {
  final Color color;
  final bool isNorth;

  ArrowPainter({required this.color, required this.isNorth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isNorth) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width / 2, size.height * 0.6);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width / 2, size.height * 0.4);
      path.lineTo(size.width, 0);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QiblaArrowPainter extends CustomPainter {
  final Color color;

  QiblaArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2, size.height * 0.65);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final glowPath = Path();
    glowPath.moveTo(size.width / 2, -4);
    glowPath.lineTo(-6, size.height + 4);
    glowPath.lineTo(size.width / 2, size.height * 0.65 + 4);
    glowPath.lineTo(size.width + 6, size.height + 4);
    glowPath.close();
    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArcPainter extends CustomPainter {
  final Color color;
  final double diff;
  final bool isDark;

  ArcPainter({required this.color, required this.diff, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final startAngle = -(diff.abs() / 180 * pi);
    final sweepAngle = (diff.abs() / 180 * pi) * 2;

    if (diff.abs() > 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        -pi / 2 - startAngle,
        sweepAngle,
        false,
        paint,
      );

      final dotPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      for (int i = -2; i <= 2; i++) {
        if (i == 0) continue;
        final angle = -pi / 2 + (i / 2) * (diff / 180 * pi);
        final dotRadius = radius - 10;
        final dx = center.dx + dotRadius * cos(angle);
        final dy = center.dy + dotRadius * sin(angle);
        canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
