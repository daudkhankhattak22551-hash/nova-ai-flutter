import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../models/history/chat_history_model.dart';
import '../../services/history/chat_history_service.dart';
import '../../services/settings/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ChatHistoryService _historyService = ChatHistoryService();
  List<ChatHistory> _recentChats = [];
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuart,
    ));

    _entranceController.forward();
  }

  void _loadRecentChats() {
    if (mounted) {
      setState(() {
        final allHistory = _historyService.getAllHistory();
        _recentChats = allHistory.take(3).toList();
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = SettingsService.userName;
    final isPremium = SettingsService.isPremium;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Stack(
        children: [
          // Background Aesthetic Glows
          if (isDark) ...[
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.04),
                ),
              ),
            ),
          ],
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: _buildHeader(context, userName, isDark, isPremium),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: isPremium 
                          ? _buildPremiumStatusCard(context, isDark) 
                          : _buildHeroCard(context, isDark),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: "EXPLORE POSSIBILITIES"),
                            const SizedBox(height: 16),
                            _buildFeatureGrid(context, isDark),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                        child: SectionHeader(
                          title: "RECENT ACTIVITY",
                          actionLabel: _recentChats.isNotEmpty ? "View All" : null,
                          onActionPressed: () {
                             // Assuming history is at index 2 or navigating to history screen
                             Navigator.pushNamed(context, AppRoutes.history);
                          },
                        ),
                      ),
                    ),

                    if (_recentChats.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: PremiumCard(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, 
                                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1), 
                                    size: 48),
                                  const SizedBox(height: 16),
                                  Text("Your conversations will appear here", 
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.4),
                                    )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildRecentChatTile(context, _recentChats[index], isDark),
                            childCount: _recentChats.length,
                          ),
                        ),
                      ),

                    if (!isPremium)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildUpgradeBanner(context, isDark),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, bool isDark, bool isPremium) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  userName.split(' ').first,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                    letterSpacing: -1.0,
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                  ),
                ],
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile).then((_) => setState(() {})),
          child: Hero(
            tag: 'profile-avatar',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      hasGlow: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [AppColors.primary.withOpacity(0.1), Colors.transparent]
              : [AppColors.primary.withOpacity(0.04), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "NEW UPDATES",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "How can Nova\nhelp you today?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontFamily: 'Poppins',
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: "New Conversation",
              icon: Icons.chat_bubble_rounded,
              isFullWidth: false,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(BuildContext context, bool isDark) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      hasGlow: true,
      gradient: AppColors.primaryGradient,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  "NOVA PRO ACTIVE",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Unlimited creative\npower is yours.",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Poppins',
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Resume Chatting",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureCard(
          context,
          "Vision AI",
          "Create art from text",
          Icons.palette_rounded,
          const Color(0xFFF59E0B),
          () => Navigator.pushNamed(context, AppRoutes.imageGenerator),
          isDark,
        ),
        _buildFeatureCard(
          context,
          "Voice AI",
          "Talk to Nova",
          Icons.graphic_eq_rounded,
          const Color(0xFF10B981),
          () => Navigator.pushNamed(context, AppRoutes.voiceAssistant),
          isDark,
        ),
        _buildFeatureCard(
          context,
          "Analysis",
          "Data insights",
          Icons.insights_rounded,
          const Color(0xFF3B82F6),
          () {},
          isDark,
        ),
        _buildFeatureCard(
          context,
          "History",
          "Review past chats",
          Icons.history_rounded,
          const Color(0xFF8B5CF6),
          () => Navigator.pushNamed(context, AppRoutes.history),
          isDark,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, 
    String title, 
    String desc, 
    IconData icon, 
    Color color, 
    VoidCallback onTap, 
    bool isDark
  ) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChatTile(BuildContext context, ChatHistory chat, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => Navigator.pushNamed(context, AppRoutes.chat, arguments: chat.id),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getTimeAgo(chat.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, bool isDark) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      gradient: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Get Nova Pro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Faster responses & advanced AI models.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.premium).then((_) => setState(() {})),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Upgrade Now",
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 60),
        ],
      ),
    );
  }
}
