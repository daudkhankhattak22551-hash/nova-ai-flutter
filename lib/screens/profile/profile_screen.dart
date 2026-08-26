import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../services/settings/settings_service.dart';
import '../../services/history/chat_history_service.dart';
import '../../services/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late String _name;
  late String _bio;
  late String _email;
  final ChatHistoryService _historyService = ChatHistoryService();
  int _chatCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _name = user?.name ?? SettingsService.userName;
    _bio = user?.bio ?? SettingsService.userBio;
    _email = user?.email ?? 'No email available';
    _chatCount = _historyService.getAllHistory().length;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final bioController = TextEditingController(text: _bio);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.cardDark 
            : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Poppins', letterSpacing: -0.5),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: "Display Name",
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (value) => 
                    (value == null || value.trim().isEmpty) ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: bioController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: "Bio",
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          PremiumButton(
            text: "Save",
            isFullWidth: false,
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await AuthService.updateProfile(
                  name: nameController.text.trim(),
                  bio: bioController.text.trim(),
                );
                setState(() {
                  _name = nameController.text.trim();
                  _bio = bioController.text.trim();
                });
                if (mounted) Navigator.pop(context);
              }
            },
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
        content: const Text("Are you sure you want to log out of your session?", style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
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
      appBar: const PremiumAppBar(title: "Profile"),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Hero Profile Header
              _buildHeroHeader(isDark, isPremium),
              const SizedBox(height: 32),

              // Stats Row
              _buildStatsRow(isDark),
              const SizedBox(height: 32),

              _buildSectionTitle("ACCOUNT INFORMATION"),
              const SizedBox(height: 12),
              _buildActionCard(isDark, [
                _buildProfileItem(
                  icon: Icons.person_outline_rounded,
                  title: "Display Name",
                  subtitle: _name,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileItem(
                  icon: Icons.email_outlined,
                  title: "Email Address",
                  subtitle: _email,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildProfileItem(
                  icon: Icons.info_outline_rounded,
                  title: "Bio",
                  subtitle: _bio,
                  isDark: isDark,
                ),
              ]),

              const SizedBox(height: 32),
              _buildSectionTitle("QUICK LINKS"),
              const SizedBox(height: 12),
              _buildActionCard(isDark, [
                _buildProfileItem(
                  icon: Icons.history_rounded,
                  title: "My Conversations",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                  isDark: isDark,
                  showArrow: true,
                ),
                _buildDivider(isDark),
                _buildProfileItem(
                  icon: Icons.settings_outlined,
                  title: "App Settings",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  isDark: isDark,
                  showArrow: true,
                ),
              ]),
              
              const SizedBox(height: 48),
              PremiumButton(
                text: "Edit Profile",
                icon: Icons.edit_rounded,
                onPressed: _showEditProfileDialog,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _showLogoutDialog,
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(bool isDark, bool isPremium) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : Colors.white,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (isPremium)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          isPremium ? "Nova AI Premium Explorer" : "Nova AI Explorer",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: PremiumCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  _chatCount.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const Text(
                  "Chats",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PremiumCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  "0", // Simplified
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  "Creations",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(bool isDark, List<Widget> children) {
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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required bool isDark,
    bool showArrow = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: IconContainer(
        icon: icon,
        color: AppColors.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
        ),
      ) : null,
      trailing: showArrow ? Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3),
      ) : null,
    );
  }
}
