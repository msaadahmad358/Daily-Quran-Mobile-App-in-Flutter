import 'package:flutter/material.dart';
import 'package:qrn_app/main.dart';
import 'translations.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final bool isDarkMode;
  final String currentLanguage;
  final String userName;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.isDarkMode,
    required this.currentLanguage,
    required this.userName,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });

    // Auto-continue after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onContinue();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);
    final userName = widget.userName.isNotEmpty ? widget.userName : 'Guest';

    // Generate a random gratitude message for variety
    final gratitudeMessages = [
      getText('welcomeMessage'),
      getText('gratitudeMessage1'),
      getText('gratitudeMessage2'),
      getText('gratitudeMessage3'),
      getText('gratitudeMessage4'),
    ];

    final randomMessage =
        gratitudeMessages[DateTime.now().day % gratitudeMessages.length];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A96E).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Heart/Charity Icon with ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A5F4A), Color(0xFF0D3B2E)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1A5F4A,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Color(0xFF1A5F4A),
                                size: 50,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ===== FIXED: Greeting =====
                          Text(
                            '🌙 ${getText('salam')}, $userName',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // ===== FIXED: Thank you message =====
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        const Color(0xFF1A3A2E),
                                        const Color(0xFF0D2B1E),
                                      ]
                                    : [
                                        const Color(0xFF1A5F4A),
                                        const Color(0xFF0D3B2E),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1A5F4A,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: Color(0xFFC9A96E),
                                  size: 40,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  getText('welcomeSubtitle'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC9A96E,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFC9A96E,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    randomMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFC9A96E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ===== FIXED: Impact stat cards =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildImpactCard(
                                isDark: isDark,
                                icon: Icons.restaurant,
                                label: getText('mealsProvided'),
                                value: '12,847',
                              ),
                              const SizedBox(width: 16),
                              _buildImpactCard(
                                isDark: isDark,
                                icon: Icons.water_drop,
                                label: getText('waterAccess'),
                                value: '9,231',
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // ===== FIXED: Continue button =====
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.onContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A5F4A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                getText('continueToApp'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ===== FIXED: Auto-dismiss timer =====
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]?.withValues(alpha: 0.5)
                                  : Colors.grey[200]?.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: Color(0xFFC9A96E),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  getText('continuingAutomatically'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, color: const Color(0xFFC9A96E), size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
