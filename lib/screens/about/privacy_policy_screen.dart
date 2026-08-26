import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: const PremiumAppBar(title: "Privacy Policy"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              isDark,
              "Overview",
              "Nova AI is committed to protecting your privacy. This policy explains how we handle your data when you use our AI assistant app.",
            ),
            _buildSection(
              isDark,
              "AI Data Processing",
              "When you interact with Nova AI, your prompts are sent to external AI providers (like Groq) to generate responses. We do not store these prompts on our servers, but the AI providers may process them according to their own privacy policies.",
            ),
            _buildSection(
              isDark,
              "Sensitive Information",
              "We strongly advise users NOT to enter sensitive personal information, passwords, financial data, or private health information into the chat. AI responses are generated based on large-scale data and may not always be secure or accurate.",
            ),
            _buildSection(
              isDark,
              "Local Storage",
              "Your chat history and profile settings are stored locally on your device using Hive. This data remains on your phone and is not uploaded to our servers. You can clear your history at any time from the Settings menu.",
            ),
            _buildSection(
              isDark,
              "API Keys",
              "Nova AI uses secure methods to handle API keys. These keys are not exposed to users and are used solely for the functionality of the app.",
            ),
            _buildSection(
              isDark,
              "Third-Party Services",
              "Our app integrates with third-party services for AI processing and image generation. Please be aware that these services have their own privacy practices.",
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Last Updated: October 2024",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        PremiumCard(
          padding: const EdgeInsets.all(20),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
