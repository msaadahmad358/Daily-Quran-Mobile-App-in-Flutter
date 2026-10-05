import 'package:flutter/material.dart';
import 'package:qrn_app/prayer_cities.dart';

class PrayerCitySearchScreen extends StatefulWidget {
  final bool isDarkMode;

  const PrayerCitySearchScreen({super.key, required this.isDarkMode});

  @override
  State<PrayerCitySearchScreen> createState() => _PrayerCitySearchScreenState();
}

class _PrayerCitySearchScreenState extends State<PrayerCitySearchScreen> {
  static const _primary = Color(0xFF1A5F4A);
  final _controller = TextEditingController();
  List<Map<String, String>> _results = kPrayerWorldCities;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _results = kPrayerWorldCities;
        return;
      }
      _results = kPrayerWorldCities.where((entry) {
        final city = entry['city']!.toLowerCase();
        final country = entry['country']!.toLowerCase();
        return city.contains(q) || country.contains(q);
      }).toList();
    });
  }

  void _select(Map<String, String> entry) {
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF7F5F2);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search City',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQuery,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Type city or country',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      'No cities found',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = _results[index];
                      final city = entry['city']!;
                      final country = entry['country']!;
                      return Material(
                        color: card,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _select(entry),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.location_city_rounded,
                                    color: _primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        city,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (country.isNotEmpty)
                                        Text(
                                          country,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
