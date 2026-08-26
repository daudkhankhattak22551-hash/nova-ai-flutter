import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: PremiumAppBar(
        title: "Voice Assistant",
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            _buildMicrophoneSection(isDark),
            const Spacer(flex: 2),
            _buildConversationPreview(isDark),
            const SizedBox(height: 32),
            _buildBottomControls(context, isDark),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneSection(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (_isListening)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRing(2.0 * _pulseAnimation.value, 0.05),
                      _buildRing(1.6 * _pulseAnimation.value, 0.1),
                      _buildRing(1.2 * _pulseAnimation.value, 0.15),
                    ],
                  );
                },
              ),
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
        Text(
          _isListening ? "I'm Listening..." : "Tap to Speak",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontFamily: 'Poppins',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening ? "Go ahead, Nova is all ears" : "Ask me anything using your voice",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildRing(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _buildConversationPreview(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          children: [
            _buildPreviewBubble("How can I help you today?", true, isDark),
            const SizedBox(height: 16),
            _buildPreviewBubble("Tell me a creative story.", false, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBubble(String text, bool isAI, bool isDark) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAI
              ? (isDark ? AppColors.surfaceDark : AppColors.background)
              : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAI ? 4 : 16),
            bottomRight: Radius.circular(isAI ? 16 : 4),
          ),
          border: isAI ? Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5)) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isAI
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                : Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(Icons.language_rounded, "English", isDark),
          _buildControlButton(Icons.graphic_eq_rounded, "Soft", isDark),
          _buildControlButton(
            Icons.history_rounded,
            "History",
            isDark,
            onTap: () => Navigator.pushNamed(context, AppRoutes.history),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          IconContainer(
            icon: icon,
            color: AppColors.primary,
            size: 24,
            padding: 18,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
