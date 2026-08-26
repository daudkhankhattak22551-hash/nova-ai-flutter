import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../services/settings/settings_service.dart';
import '../../services/history/chat_history_service.dart';
import '../../services/auth/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ChatHistoryService _historyService = ChatHistoryService();
  late String _selectedModel;
  late String _responseStyle;
  late double _temperature;

  @override
  void initState() {
    super.initState();
    _selectedModel = SettingsService.aiModel;
    _responseStyle = SettingsService.responseStyle;
    _temperature = SettingsService.temperature;
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          "Clear All History?",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        content: const Text(
          "This will permanently delete all your saved conversations. This action cannot be undone.",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              
              await _historyService.deleteAllHistory();
              
              if (mounted) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text("All history cleared", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            child: const Text("Clear All", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Log Out?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
        content: const Text("Are you sure you want to log out of your session?", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AuthService.logout();
              if (mounted) {
                navigator.pop();
                navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            child: const Text("Log Out", style: TextStyle(fontFamily: 'Poppins', color: AppColors.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService.currentUser;
    final isPremium = user?.isPremium ?? SettingsService.isPremium;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: const PremiumAppBar(title: "Settings"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPremium) ...[
              _buildPremiumPromo(isDark),
              const SizedBox(height: 32),
            ],
            
            _buildSectionTitle("ACCOUNT"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildListTile(
                "Profile Details",
                Icons.person_outline_rounded,
                () => Navigator.pushNamed(context, AppRoutes.profile),
                isDark,
                trailingText: user?.name,
              ),
              _buildDivider(isDark),
              _buildListTile(
                isPremium ? "Manage Subscription" : "Upgrade to Premium",
                Icons.workspace_premium_rounded,
                () => Navigator.pushNamed(context, AppRoutes.premium).then((_) => setState(() {})),
                isDark,
                trailingText: isPremium ? "Active" : "Free Plan",
              ),
            ]),
            const SizedBox(height: 32),

            _buildSectionTitle("AI PREFERENCES"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildDropdownTile(
                "Intelligence Model",
                _selectedModel,
                ['llama-3.3-70b-versatile', 'llama3-8b-8192', 'mixtral-8x7b-32768'],
                (val) async {
                  if (val != null) {
                    await SettingsService.setAiModel(val);
                    setState(() => _selectedModel = val);
                  }
                },
                Icons.psychology_rounded,
                isDark,
              ),
              _buildDivider(isDark),
              _buildDropdownTile(
                "Response Style",
                _responseStyle,
                ['Balanced', 'Creative', 'Precise', 'Concise'],
                (val) async {
                  if (val != null) {
                    await SettingsService.setResponseStyle(val);
                    setState(() => _responseStyle = val);
                  }
                },
                Icons.auto_awesome_rounded,
                isDark,
              ),
              _buildDivider(isDark),
              _buildSliderTile(
                "Creativity (Temperature)",
                _temperature,
                (val) async {
                  await SettingsService.setTemperature(val);
                  setState(() => _temperature = val);
                },
                Icons.tune_rounded,
                isDark,
              ),
            ]),
            const SizedBox(height: 32),

            _buildSectionTitle("APPEARANCE"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildThemeTile(isDark),
            ]),
            const SizedBox(height: 32),

            _buildSectionTitle("INFORMATION"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildInfoTile("App Name", AppStrings.appName, isDark),
              _buildDivider(isDark),
              _buildInfoTile("Version", "1.0.2", isDark),
              _buildDivider(isDark),
              _buildListTile("About Nova AI", Icons.info_outline_rounded, () {
                Navigator.pushNamed(context, AppRoutes.about);
              }, isDark),
              _buildDivider(isDark),
              _buildListTile("Privacy Policy", Icons.privacy_tip_rounded, () {
                Navigator.pushNamed(context, AppRoutes.privacyPolicy);
              }, isDark),
              _buildDivider(isDark),
              _buildListTile("Terms of Service", Icons.description_rounded, () {
                Navigator.pushNamed(context, AppRoutes.terms);
              }, isDark),
            ]),
            const SizedBox(height: 32),

            _buildSectionTitle("DATA & PRIVACY"),
            const SizedBox(height: 12),
            _buildSettingsCard(isDark, [
              _buildListTile(
                "Clear Conversation History",
                Icons.delete_sweep_rounded,
                _showClearHistoryDialog,
                isDark,
                isDestructive: true,
              ),
              _buildDivider(isDark),
              _buildListTile(
                "Sign Out",
                Icons.logout_rounded,
                _showLogoutDialog,
                isDark,
                isDestructive: true,
              ),
            ]),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPromo(bool isDark) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      gradient: AppColors.primaryGradient,
      onTap: () => Navigator.pushNamed(context, AppRoutes.premium).then((_) => setState(() {})),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Get Unlimited Access",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  "Unlock GPT-4 and all premium features.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.primary.withValues(alpha: 0.8),
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 20,
      color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap, bool isDark, {bool isDestructive = false, String? trailingText}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: IconContainer(
        icon: icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDestructive ? AppColors.error : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Flexible(
              child: Text(
                trailingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> items, ValueChanged<String?> onChanged, IconData icon, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: IconContainer(icon: icon, color: AppColors.primary, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 18),
          onChanged: onChanged,
          dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }

  Widget _buildSliderTile(String title, double value, ValueChanged<double> onChanged, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            leading: IconContainer(icon: icon, color: AppColors.primary, size: 20),
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(68, 0, 24, 8),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: IconContainer(
        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: AppColors.primary,
        size: 20,
      ),
      title: Text(
        "Dark Mode",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDark,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        onChanged: (val) async {
          await SettingsService.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
          widget.onThemeChanged();
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
