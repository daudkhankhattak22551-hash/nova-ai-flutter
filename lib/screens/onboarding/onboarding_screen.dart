import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../services/settings/settings_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Elevate Your\nIntelligence",
      subtitle: "Meet Nova, your advanced AI companion designed to boost your productivity and creativity.",
      icon: Icons.auto_awesome_rounded,
      glowColor: AppColors.primary,
    ),
    OnboardingData(
      title: "Conversations\nWithout Limits",
      subtitle: "Experience natural, context-aware dialogues that help you solve complex problems instantly.",
      icon: Icons.forum_rounded,
      glowColor: AppColors.secondary,
    ),
    OnboardingData(
      title: "Artistic\nVisionary",
      subtitle: "Transform your words into stunning visual masterpieces with our state-of-the-art image generator.",
      icon: Icons.palette_rounded,
      glowColor: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await SettingsService.setOnboardingCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Stack(
        children: [
          // Background subtle glows
          if (isDark) ...[
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pages[_currentPage].glowColor.withOpacity(0.08),
                ),
              ),
            ),
          ],
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIllustration(data, isDark, index == _currentPage),
                            const SizedBox(height: 60),
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                                letterSpacing: -1.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              data.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.7),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 48),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildDot(index: index, isDark: isDark),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      PremiumButton(
                        text: _currentPage == _pages.length - 1 ? "Start Your Journey" : "Continue",
                        gradient: _currentPage == 0 ? AppColors.primaryGradient : (_currentPage == 1 ? [AppColors.secondary, AppColors.accent] : AppColors.accentGradient),
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutQuart,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(OnboardingData data, bool isDark, bool isActive) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 600),
      scale: isActive ? 1.0 : 0.8,
      curve: Curves.easeOutBack,
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: data.glowColor.withOpacity(isDark ? 0.05 : 0.03),
        ),
        child: Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [data.glowColor, data.glowColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.glowColor.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required int index, required bool isDark}) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary 
            : (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
  });
}
