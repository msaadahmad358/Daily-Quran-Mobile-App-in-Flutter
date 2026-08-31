import 'package:flutter/material.dart';
import 'translations.dart';
import 'base_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const SubscriptionScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends BaseScreenState<SubscriptionScreen> {
  int _selectedPlan = -1;
  final int _fixedPrice = 30; // €30 per month

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
          getText('subscription'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A5F4A), Color(0xFF0D3B2E)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Color(0xFFC9A96E), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    getText('premiumAccess'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getText('choosePlan'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plan Cards - All at €30/month
            _buildPlanCard(
              isDark: isDark,
              title: getText('basic'),
              price: '${getText('euro')}30',
              description: getText('basicDesc'),
              features: [
                'Access to all Quran translations',
                'Daily verse notifications',
                'Basic dua library',
                'Qibla compass',
                'Prayer times',
                'Reading history',
              ],
              isSelected: _selectedPlan == 0,
              onTap: () => setState(() => _selectedPlan = 0),
            ),

            const SizedBox(height: 12),

            _buildPlanCard(
              isDark: isDark,
              title: getText('premium'),
              price: '${getText('euro')}30',
              description: getText('premiumDesc'),
              features: [
                'Everything in Basic',
                'Advanced audio recitation',
                'Tafsir and commentary',
                'Offline mode',
                'Priority support',
                'No ads',
                'Multiple translations',
              ],
              isPopular: true,
              isSelected: _selectedPlan == 1,
              onTap: () => setState(() => _selectedPlan = 1),
            ),

            const SizedBox(height: 12),

            _buildPlanCard(
              isDark: isDark,
              title: getText('family'),
              price: '${getText('euro')}30',
              description: getText('familyDesc'),
              features: [
                'Everything in Premium',
                'Share with 5 family members',
                'Family progress tracking',
                'Kids learning module',
                'Family dashboard',
              ],
              isSelected: _selectedPlan == 2,
              onTap: () => setState(() => _selectedPlan = 2),
            ),

            const SizedBox(height: 32),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedPlan != -1
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(getText('subscriptionStarted')),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5F4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
                child: Text(
                  _selectedPlan != -1
                      ? '${getText('subscribe')} ${getText('euro')}30 ${getText('perMonth')}'
                      : getText('selectPlan'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    getText('cancelAnytime'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    getText('securePayment'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required bool isDark,
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A5F4A)
                : isPopular
                ? const Color(0xFFC9A96E)
                : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE8E0D8)),
            width: isSelected || isPopular ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            if (isPopular && !isSelected)
              BoxShadow(
                color: const Color(0xFFC9A96E).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A96E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          getText('popular'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF1A5F4A),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF1A5F4A)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white70
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A5F4A),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white70
                              : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
