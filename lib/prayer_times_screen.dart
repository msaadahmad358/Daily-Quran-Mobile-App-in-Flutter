import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'translations.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'base_screen.dart';

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
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCity = 'Paris';
  bool _hasLocation = false;
  bool _isUsingLocation = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];
  List<String> _allCities = [];
  String _currentCountry = '';
  bool _isWeb = false;
  bool _isLocationLoading = false;

  final List<Map<String, String>> _worldCities = [
    // Europe
    {'city': 'Paris', 'country': 'France'},
    {'city': 'London', 'country': 'United Kingdom'},
    {'city': 'Berlin', 'country': 'Germany'},
    {'city': 'Madrid', 'country': 'Spain'},
    {'city': 'Rome', 'country': 'Italy'},
    {'city': 'Amsterdam', 'country': 'Netherlands'},
    {'city': 'Brussels', 'country': 'Belgium'},
    {'city': 'Vienna', 'country': 'Austria'},
    {'city': 'Zurich', 'country': 'Switzerland'},
    {'city': 'Stockholm', 'country': 'Sweden'},
    {'city': 'Oslo', 'country': 'Norway'},
    {'city': 'Copenhagen', 'country': 'Denmark'},
    {'city': 'Helsinki', 'country': 'Finland'},
    {'city': 'Dublin', 'country': 'Ireland'},
    {'city': 'Lisbon', 'country': 'Portugal'},
    {'city': 'Athens', 'country': 'Greece'},
    {'city': 'Warsaw', 'country': 'Poland'},
    {'city': 'Prague', 'country': 'Czech Republic'},
    {'city': 'Budapest', 'country': 'Hungary'},
    {'city': 'Moscow', 'country': 'Russia'},
    {'city': 'Istanbul', 'country': 'Turkey'},
    // North America
    {'city': 'New York', 'country': 'United States'},
    {'city': 'Los Angeles', 'country': 'United States'},
    {'city': 'Chicago', 'country': 'United States'},
    {'city': 'Houston', 'country': 'United States'},
    {'city': 'Toronto', 'country': 'Canada'},
    {'city': 'Vancouver', 'country': 'Canada'},
    {'city': 'Montreal', 'country': 'Canada'},
    {'city': 'Mexico City', 'country': 'Mexico'},
    // South America
    {'city': 'Sao Paulo', 'country': 'Brazil'},
    {'city': 'Rio de Janeiro', 'country': 'Brazil'},
    {'city': 'Buenos Aires', 'country': 'Argentina'},
    {'city': 'Santiago', 'country': 'Chile'},
    {'city': 'Lima', 'country': 'Peru'},
    {'city': 'Bogota', 'country': 'Colombia'},
    // Middle East
    {'city': 'Mecca', 'country': 'Saudi Arabia'},
    {'city': 'Medina', 'country': 'Saudi Arabia'},
    {'city': 'Riyadh', 'country': 'Saudi Arabia'},
    {'city': 'Dubai', 'country': 'United Arab Emirates'},
    {'city': 'Abu Dhabi', 'country': 'United Arab Emirates'},
    {'city': 'Doha', 'country': 'Qatar'},
    {'city': 'Kuwait City', 'country': 'Kuwait'},
    {'city': 'Muscat', 'country': 'Oman'},
    {'city': 'Bahrain', 'country': 'Bahrain'},
    {'city': 'Tehran', 'country': 'Iran'},
    {'city': 'Baghdad', 'country': 'Iraq'},
    {'city': 'Amman', 'country': 'Jordan'},
    {'city': 'Beirut', 'country': 'Lebanon'},
    {'city': 'Damascus', 'country': 'Syria'},
    {'city': 'Jerusalem', 'country': 'Palestine'},
    {'city': 'Cairo', 'country': 'Egypt'},
    {'city': 'Alexandria', 'country': 'Egypt'},
    {'city': 'Tripoli', 'country': 'Libya'},
    {'city': 'Tunis', 'country': 'Tunisia'},
    {'city': 'Algiers', 'country': 'Algeria'},
    {'city': 'Rabat', 'country': 'Morocco'},
    {'city': 'Casablanca', 'country': 'Morocco'},
    // Asia
    {'city': 'Kuala Lumpur', 'country': 'Malaysia'},
    {'city': 'Jakarta', 'country': 'Indonesia'},
    {'city': 'Singapore', 'country': 'Singapore'},
    {'city': 'Bangkok', 'country': 'Thailand'},
    {'city': 'Manila', 'country': 'Philippines'},
    {'city': 'Hong Kong', 'country': 'China'},
    {'city': 'Shanghai', 'country': 'China'},
    {'city': 'Beijing', 'country': 'China'},
    {'city': 'Tokyo', 'country': 'Japan'},
    {'city': 'Seoul', 'country': 'South Korea'},
    {'city': 'Mumbai', 'country': 'India'},
    {'city': 'Delhi', 'country': 'India'},
    {'city': 'Bangalore', 'country': 'India'},
    {'city': 'Karachi', 'country': 'Pakistan'},
    {'city': 'Lahore', 'country': 'Pakistan'},
    {'city': 'Islamabad', 'country': 'Pakistan'},
    {'city': 'Dhaka', 'country': 'Bangladesh'},
    {'city': 'Colombo', 'country': 'Sri Lanka'},
    {'city': 'Kathmandu', 'country': 'Nepal'},
    // Africa
    {'city': 'Cape Town', 'country': 'South Africa'},
    {'city': 'Johannesburg', 'country': 'South Africa'},
    {'city': 'Nairobi', 'country': 'Kenya'},
    {'city': 'Dar es Salaam', 'country': 'Tanzania'},
    {'city': 'Lagos', 'country': 'Nigeria'},
    {'city': 'Abuja', 'country': 'Nigeria'},
    {'city': 'Accra', 'country': 'Ghana'},
    {'city': 'Dakar', 'country': 'Senegal'},
    {'city': 'Khartoum', 'country': 'Sudan'},
    {'city': 'Addis Ababa', 'country': 'Ethiopia'},
    // Oceania
    {'city': 'Sydney', 'country': 'Australia'},
    {'city': 'Melbourne', 'country': 'Australia'},
    {'city': 'Brisbane', 'country': 'Australia'},
    {'city': 'Perth', 'country': 'Australia'},
    {'city': 'Auckland', 'country': 'New Zealand'},
  ];

  @override
  void initState() {
    super.initState();
    _allCities = _worldCities.map((c) => c['city']!).toList();
    _filteredCities = _allCities;
    _isWeb = kIsWeb;
    _getLocationAndPrayerTimes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities.where((city) {
          final cityLower = city.toLowerCase();
          final match = _worldCities.firstWhere(
            (c) => c['city']!.toLowerCase() == cityLower,
            orElse: () => {'city': city, 'country': ''},
          );
          final country = match['country']?.toLowerCase() ?? '';
          return cityLower.contains(_searchQuery) ||
              country.contains(_searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _getLocationAndPrayerTimes() async {
    setState(() {
      _isLoading = true;
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
        setState(() {
          _hasLocation = true;
          _isUsingLocation = true;
          _isLocationLoading = false;
        });
        await _fetchPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await _getLocationName(position.latitude, position.longitude);
        setState(() {
          _isLoading = false;
        });
        return;
      } catch (e) {
        // Web location failed, fallback to selected city
        setState(() {
          _errorMessage =
              '🌐 Web: Unable to get location. Using selected city.';
          _isUsingLocation = false;
          _isLocationLoading = false;
        });
        await _fetchPrayerTimes(city: _selectedCity);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Mobile: Request location permission
    final locationStatus = await Permission.location.request();

    if (locationStatus.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
        setState(() {
          _hasLocation = true;
          _isUsingLocation = true;
          _isLocationLoading = false;
        });
        await _fetchPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await _getLocationName(position.latitude, position.longitude);
      } catch (e) {
        setState(() {
          _errorMessage = 'Unable to get location. Using selected city.';
          _isUsingLocation = false;
          _isLocationLoading = false;
        });
        await _fetchPrayerTimes(city: _selectedCity);
      }
    } else {
      setState(() {
        _errorMessage = 'Location permission denied. Using selected city.';
        _isUsingLocation = false;
        _isLocationLoading = false;
      });
      await _fetchPrayerTimes(city: _selectedCity);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getLocationName(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10';
      final response = await http.get(Uri.parse(url));

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
          if (city != null && _allCities.contains(city)) {
            setState(() {
              _selectedCity = city;
              _currentCountry = address['country'] ?? '';
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
  }) async {
    try {
      String url;
      if (latitude != null && longitude != null) {
        url =
            'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2';
      } else {
        url =
            'https://api.aladhan.com/v1/timingsByCity?city=${city ?? _selectedCity}&country=&method=2';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final timings = data['data']['timings'];
          final date = data['data']['date']['readable'];

          setState(() {
            _prayerTimes = {
              'date': date,
              'Fajr': timings['Fajr'],
              'Sunrise': timings['Sunrise'],
              'Dhuhr': timings['Dhuhr'],
              'Asr': timings['Asr'],
              'Maghrib': timings['Maghrib'],
              'Isha': timings['Isha'],
            };
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(
          getText('prayerTimes'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _getLocationAndPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _isLocationLoading
                        ? getText('gettingLocation')
                        : getText('pleaseWait'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty && _prayerTimes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getLocationAndPrayerTimes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5F4A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(getText('retry')),
                  ),
                ],
              ),
            )
          : _prayerTimes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getText('noPrayerTimes'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Selector with Search
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                            : [Colors.white, const Color(0xFFF8F5F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: _filterCities,
                          onTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: getText('searchCity'),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color(0xFF1A5F4A),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _filteredCities = _allCities;
                                        _isSearching = false;
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0EDE8),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (_isSearching || _searchController.text.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3D3D3D)
                                    : const Color(0xFFE8E0D8),
                                width: 1,
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: _filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = _filteredCities[index];
                                final cityData = _worldCities.firstWhere(
                                  (c) => c['city'] == city,
                                  orElse: () => {'city': city, 'country': ''},
                                );
                                final country = cityData['country'] ?? '';

                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.location_city,
                                    color: const Color(0xFF1A5F4A),
                                    size: 18,
                                  ),
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: country.isNotEmpty
                                      ? Text(
                                          country,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        )
                                      : null,
                                  onTap: () async {
                                    setState(() {
                                      _selectedCity = city;
                                      _isSearching = false;
                                      _isUsingLocation = false;
                                      _isLoading = true;
                                      _searchController.clear();
                                      _filteredCities = _allCities;
                                    });
                                    await _fetchPrayerTimes(city: city);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                );
                              },
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSearching = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2A2A)
                                          : const Color(0xFFF0EDE8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isUsingLocation
                                              ? Icons.gps_fixed
                                              : Icons.location_city,
                                          color: _isUsingLocation
                                              ? Colors.green
                                              : const Color(0xFF1A5F4A),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _isUsingLocation
                                                ? '📍 $_selectedCity'
                                                : _selectedCity,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (_isUsingLocation && _hasLocation)
                                const SizedBox(width: 8),
                              if (_isUsingLocation && _hasLocation)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        getText('currentLocation'),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date
                  if (_prayerTimes.containsKey('date'))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: const Color(0xFF1A5F4A),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _prayerTimes['date'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Prayer times
                  ...['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                      .map(
                        (prayer) => _buildPrayerCard(
                          isDark: isDark,
                          name: getText(prayer.toLowerCase()),
                          time: _prayerTimes[prayer] ?? '--:--',
                          isNext: prayer == _getNextPrayer(),
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 20),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC9A96E).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFC9A96E),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            getText('citiesAvailable').replaceAll(
                              '{count}',
                              _allCities.length.toString(),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Permission status for iOS/Android
                  if (!_isWeb && !_hasLocation)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 12),
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
                            Icons.gps_off,
                            color: Colors.orange[700],
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              Platform.isIOS
                                  ? getText('enableLocationSettings')
                                  : getText('enableLocationAccurate'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (Platform.isIOS) {
                                openAppSettings();
                              } else {
                                _getLocationAndPrayerTimes();
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
                                  ? getText('settings')
                                  : getText('retry'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Web location status
                  if (_isWeb && !_hasLocation)
                    Container(
                      padding: const EdgeInsets.all(12),
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
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerCard({
    required bool isDark,
    required String name,
    required String time,
    required bool isNext,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isNext
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                    : [Colors.white, const Color(0xFFF8F5F0)],
              ),
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? null
            : Border.all(
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFE8E0D8),
                width: 1,
              ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNext
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFF1A5F4A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(name),
              color: isNext ? Colors.white : const Color(0xFF1A5F4A),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isNext
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (isNext)
                  Text(
                    getText('nextPrayer'),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isNext
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isNext
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextPrayer() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    final prayers = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final prayer in prayers) {
      final timeStr = _prayerTimes[prayer] ?? '';
      if (timeStr.isEmpty) continue;

      try {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1].split(' ')[0]);

          if (hour > currentHour ||
              (hour == currentHour && minute > currentMinute)) {
            return prayer;
          }
        }
      } catch (e) {
        continue;
      }
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
