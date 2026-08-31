import 'package:flutter/material.dart';
import 'translations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final String currentLanguage;
  final bool isDarkMode;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.currentLanguage,
    required this.isDarkMode,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = const [
    {
      'title': 'onboarding1',
      'desc': 'onboarding1Desc',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdaq4PNR4G89soBiP3m37_H55aOlkhjZJWzGfvvFRC1Q&s=10',
    },
    {
      'title': 'onboarding2',
      'desc': 'onboarding2Desc',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb30JhLrjGNXEMm6Xg5H8-k-_rMnaT2wUS9pxXN4pC0w&s=10',
    },
    {
      'title': 'onboarding3',
      'desc': 'onboarding3Desc',
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReS4Vm1XqTTxC5Q3WjrbEQ7zEWryCveGdQTkPxedaydA&s=10',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onComplete,
                    child: Text(
                      getText('skip'),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1A5F4A,
                                ).withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              data['image']!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1A5F4A,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF1A5F4A)),
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1A5F4A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Color(0xFF1A5F4A),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          getText(data['title']!),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A5F4A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          getText(data['desc']!),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentPage == index ? 30 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF1A5F4A)
                              : isDark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          widget.onComplete();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5F4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? getText('getStarted')
                            : getText('next'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
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
}
