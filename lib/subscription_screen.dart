import 'package:flutter/material.dart';
import 'translations.dart';
import 'base_screen.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';          // TODO: enable later
// import 'dart:convert';                                        // TODO
// import 'package:http/http.dart' as http;                      // TODO
// import 'package:shared_preferences/shared_preferences.dart';  // TODO
// import 'auth_service.dart';                                   // TODO

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
  // ============ PLAN SELECTION ============
  int _selectedPlan = -1;
  bool _isAnnual = false;
  bool _isProcessing = false;

  // Kept for future payment UI, not used yet
  // bool _applePayAvailable = false;
  // bool _googlePayAvailable = false;

  // ============ PRICING ============
  final Map<String, Map<String, dynamic>> _plans = {
    'basic': {
      'title': 'Basic',
      'monthly': 4.99,
      'annual': 49.99,
      'features': [
        '📖 Daily Quran verses',
        '🕋 Qibla compass',
        '🕌 Prayer times',
        '📊 Reading history',
        '💚 5 du\'as daily',
      ],
    },
    'premium': {
      'title': 'Premium',
      'monthly': 9.99,
      'annual': 99.99,
      'features': [
        '✨ All Basic features',
        '🔊 Audio recitations',
        '📚 Full Tafsir',
        '📱 Offline mode',
        '🔔 Custom notifications',
        '🎯 Advanced analytics',
        '⭐ Priority support',
      ],
    },
    'family': {
      'title': 'Family',
      'monthly': 19.99,
      'annual': 199.99,
      'features': [
        '👨‍👩‍👧‍👦 All Premium features',
        '👥 5 family members',
        '📊 Family dashboard',
        '🎯 Kids learning module',
        '📈 Family progress tracking',
        '🆓 Free for children under 12',
      ],
    },
  };

  // ============ FREE TRIAL ============
  final bool _hasFreeTrial = true; // was `bool` — now `final`
  final int _freeTrialDays = 3; // was `int` — now `final`
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    // _checkPaymentAvailability(); // TODO: enable when Stripe is configured
    // _checkSubscriptionStatus();  // TODO: enable when SharedPreferences is wired
  }

  // ============================================================
  // TODO: PAYMENT LOGIC — uncomment & adapt when ready
  // ============================================================
  //
  // Future<void> _checkPaymentAvailability() async {
  //   try {
  //     final applePay = await Stripe.instance.isPlatformPaySupported();
  //     final googlePay = await Stripe.instance.isPlatformPaySupported(
  //       googlePay: const IsGooglePaySupportedParams(testEnv: true),
  //     );
  //     setState(() {
  //       _applePayAvailable = applePay;
  //       _googlePayAvailable = googlePay;
  //     });
  //   } catch (e) {
  //     // handle error
  //   }
  // }
  //
  // Future<void> _checkSubscriptionStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final expiry = prefs.getString('subscription_expiry');
  //   if (expiry != null) {
  //     final expiryDate = DateTime.parse(expiry);
  //     if (expiryDate.isAfter(DateTime.now())) {
  //       setState(() => _isSubscribed = true);
  //     }
  //   }
  // }
  //
  // Future<Map<String, dynamic>> _processPayment({...}) async { ... }
  // Future<void> _restorePurchases() async { ... }

  // ========== PLACEHOLDER HANDLERS ==========

  Future<void> _handleSubscription() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment flow coming soon'),
        backgroundColor: Color(0xFF1A5F4A),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore purchases coming soon'),
        backgroundColor: Color(0xFF1A5F4A),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Subscription automatically renews unless cancelled 24 hours before renewal.\n\n'
            '2. Free trial available for new subscribers only.\n\n'
            '3. Manage subscriptions in App Store/Google Play settings.\n\n'
            '4. Payment processed through Apple/Google/Stripe.\n\n'
            '5. Refunds are subject to Apple/Google/Stripe policies.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
          _isSubscribed ? '🎉 Premium Active' : getText('subscription'),
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
          if (_isSubscribed)
            TextButton(
              onPressed: _restorePurchases,
              child: const Text(
                'Restore',
                style: TextStyle(color: Color(0xFF1A5F4A)),
              ),
            ),
        ],
      ),
      body: _isSubscribed
          ? _buildActiveSubscriptionUI(isDark, getText)
          : _buildSubscriptionPlansUI(isDark, getText),
    );
  }

  Widget _buildSubscriptionPlansUI(
    bool isDark,
    String Function(String) getText,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(isDark, getText),
          const SizedBox(height: 20),
          _buildBillingToggle(isDark, getText),
          const SizedBox(height: 20),

          ..._plans.entries.map((entry) {
            final key = entry.key;
            final plan = entry.value;
            final index = _plans.keys.toList().indexOf(key);
            final isSelected = _selectedPlan == index;
            final price = _isAnnual ? plan['annual'] : plan['monthly'];
            final period = _isAnnual ? 'year' : 'month';

            return _buildPlanCard(
              isDark: isDark,
              title: plan['title'],
              price: '€${price.toStringAsFixed(2)}',
              period: '/$period',
              description: _isAnnual
                  ? 'Save ${(((plan['monthly'] * 12 - plan['annual']) / (plan['monthly'] * 12) * 100).toStringAsFixed(0))}%'
                  : 'Monthly billing',
              features: List<String>.from(plan['features']),
              isSelected: isSelected,
              isPopular: key == 'premium',
              hasFreeTrial: _hasFreeTrial && !_isAnnual,
              freeTrialDays: _freeTrialDays,
              onTap: () => setState(() => _selectedPlan = index),
            );
          }),

          const SizedBox(height: 24),
          _buildPaymentMethodSelector(isDark, getText),
          const SizedBox(height: 16),
          _buildSubscribeButton(isDark, getText),
          const SizedBox(height: 12),
          _buildTermsAndConditions(isDark, getText),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader(bool isDark, String Function(String) getText) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            '🌟 ${getText('premiumAccess')}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasFreeTrial
                ? 'Start with $_freeTrialDays-day free trial!'
                : getText('choosePlan'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ========== BILLING TOGGLE ==========
  Widget _buildBillingToggle(bool isDark, String Function(String) getText) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_isAnnual
                      ? const Color(0xFF1A5F4A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      color: !_isAnnual
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: !_isAnnual
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _isAnnual
                      ? const Color(0xFF1A5F4A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Annual',
                        style: TextStyle(
                          color: _isAnnual
                              ? Colors.white
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontWeight: _isAnnual
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A96E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Save 20%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PLAN CARD ==========
  Widget _buildPlanCard({
    required bool isDark,
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isSelected,
    required bool isPopular,
    required bool hasFreeTrial,
    required int freeTrialDays,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
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
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (hasFreeTrial && !isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '$freeTrialDays days free',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white70
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                const Spacer(),
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

  // ========== PAYMENT METHOD SELECTOR ==========
  Widget _buildPaymentMethodSelector(
    bool isDark,
    String Function(String) getText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE8E0D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  isDark: isDark,
                  icon: Icons.apple,
                  label: 'Apple Pay',
                  selected: true,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildPaymentOption(
                  isDark: isDark,
                  icon: Icons.android,
                  label: 'Google Pay',
                  selected: false,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildPaymentOption(
                  isDark: isDark,
                  icon: Icons.credit_card,
                  label: 'Card',
                  selected: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required bool isDark,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A5F4A).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF1A5F4A) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF1A5F4A)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? const Color(0xFF1A5F4A)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SUBSCRIBE BUTTON ==========
  Widget _buildSubscribeButton(bool isDark, String Function(String) getText) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedPlan != -1 && !_isProcessing
            ? _handleSubscription
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5F4A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _selectedPlan != -1
                    ? _hasFreeTrial
                          ? 'Start $_freeTrialDays-Day Free Trial'
                          : 'Subscribe Now'
                    : 'Select a Plan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ========== TERMS ==========
  Widget _buildTermsAndConditions(
    bool isDark,
    String Function(String) getText,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              'Cancel anytime',
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
              'Secure payment',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showTermsDialog,
          child: Text(
            'Terms & Conditions | Privacy Policy',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ========== ACTIVE SUBSCRIPTION UI ==========
  Widget _buildActiveSubscriptionUI(
    bool isDark,
    String Function(String) getText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Color(0xFF1A5F4A), size: 80),
            const SizedBox(height: 24),
            Text(
              '🎉 You\'re a Premium Member!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for supporting Daily Quran',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('✅ All premium features unlocked'),
                  SizedBox(height: 8),
                  Text('✅ Audio recitations available'),
                  SizedBox(height: 8),
                  Text('✅ Offline mode active'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _restorePurchases,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A5F4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }
}
