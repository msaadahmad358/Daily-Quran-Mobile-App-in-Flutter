import 'package:flutter/material.dart';
import 'translations.dart';
import 'base_screen.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // TODO: uncomment when Stripe is set up
// import 'dart:convert';                                  // TODO: uncomment when payment logic is added
// import 'package:http/http.dart' as http;                // TODO: uncomment when payment logic is added
// import 'package:shared_preferences/shared_preferences.dart'; // TODO
// import 'auth_service.dart';                             // TODO

class DonationScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const DonationScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends BaseScreenState<DonationScreen> {
  bool _isRecurring = false;
  double _selectedAmount = 10.0;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustom = false;
  bool _isProcessing = false;

  // Unused for now, kept for future payment logic
  // bool _applePayAvailable = false;
  // bool _googlePayAvailable = false;

  final List<double> _presetAmounts = [5, 10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    // _checkPaymentAvailability(); // TODO: enable when Stripe is configured
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
  //     // Silent fail
  //   }
  // }
  //
  // Future<void> _donateWithApplePay() async {
  //   if (_selectedAmount <= 0) return;
  //   setState(() => _isProcessing = true);
  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://sunnahsource.org/QRN/api/payments.php'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'action': 'create_donation',
  //         'amount': (_selectedAmount * 100).toInt(),
  //         'currency': 'usd',
  //         'recurring': _isRecurring,
  //         'payment_method': 'apple_pay',
  //       }),
  //     );
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to create payment intent');
  //     }
  //     final data = jsonDecode(response.body);
  //
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: data['clientSecret'],
  //         merchantDisplayName: 'Daily Quran',
  //         applePay: const PaymentSheetApplePay(
  //           merchantCountryCode: 'US',
  //           cartItems: [
  //             ApplePayCartSummaryItem.immediate(
  //               label: 'Donation to Daily Quran',
  //               amount: '1000', // amount in cents as String
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     await Stripe.instance.presentPaymentSheet();
  //     _showThankYouDialog();
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Donation failed: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  //   if (mounted) setState(() => _isProcessing = false);
  // }

  /// Placeholder handler — shows a snackbar until payment logic is wired up.
  Future<void> _handleDonate() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Donation of \$${_selectedAmount.toStringAsFixed(2)} — payment coming soon',
        ),
        backgroundColor: const Color(0xFF1A5F4A),
      ),
    );
  }

  /// TODO: replace with a proper thank-you dialog when payment works
  // void _showThankYouDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text(getText('thankYou')),
  //       content: Text(getText('thankYouDonation').replaceAll(
  //         '{amount}', '\$${_selectedAmount.toStringAsFixed(2)}',
  //       )),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(getText('close')),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
          getText('donation'),
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
            // ===== Header =====
            Container(
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getText('donate'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          getText('supportTheApp'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== Recurring Toggle =====
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRecurring = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !_isRecurring
                              ? const Color(0xFF1A5F4A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            getText('oneTime'),
                            style: TextStyle(
                              color: !_isRecurring
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              fontWeight: !_isRecurring
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
                      onTap: () => setState(() => _isRecurring = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isRecurring
                              ? const Color(0xFF1A5F4A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            getText('recurring'),
                            style: TextStyle(
                              color: _isRecurring
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              fontWeight: _isRecurring
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== Preset Amounts =====
            Text(
              getText('selectAmount'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetAmounts.map((amount) {
                final isSelected = _selectedAmount == amount && !_isCustom;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedAmount = amount;
                    _isCustom = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (MediaQuery.of(context).size.width - 60) / 3.5,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                            )
                          : LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E1E1E),
                                      const Color(0xFF2A2A2A),
                                    ]
                                  : [Colors.white, const Color(0xFFF8F5F0)],
                            ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A5F4A)
                            : (isDark
                                  ? const Color(0xFF3D3D3D)
                                  : const Color(0xFFE8E0D8)),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(
                              0xFF1A5F4A,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (isSelected) const SizedBox(height: 4),
                        if (isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // ===== Custom Amount =====
            GestureDetector(
              onTap: () => setState(() => _isCustom = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                        : [Colors.white, const Color(0xFFF8F5F0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isCustom
                        ? const Color(0xFF1A5F4A)
                        : (isDark
                              ? const Color(0xFF3D3D3D)
                              : const Color(0xFFE8E0D8)),
                    width: _isCustom ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customAmountController,
                        onTap: () => setState(() => _isCustom = true),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _selectedAmount = double.tryParse(value) ?? 0;
                          }
                        },
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: getText('customAmount'),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isCustom
                            ? const Color(0xFF1A5F4A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getText('custom'),
                        style: TextStyle(
                          color: _isCustom
                              ? Colors.white
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontSize: 12,
                          fontWeight: _isCustom
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Donate Button =====
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedAmount > 0 && !_isProcessing
                    ? _handleDonate
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
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedAmount > 0
                                ? getText('donateNow')
                                : getText('donateNow'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    getText('secureStripe'),
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
}
