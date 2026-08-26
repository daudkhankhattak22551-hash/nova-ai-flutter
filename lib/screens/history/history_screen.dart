import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../models/history/chat_history_model.dart';
import '../../services/history/chat_history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatHistoryService _historyService = ChatHistoryService();
  
  List<ChatHistory> _allHistory = [];
  List<ChatHistory> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadHistory() {
    if (mounted) {
      setState(() {
        _allHistory = _historyService.getAllHistory();
        _filteredHistory = _allHistory;
        _onSearchChanged();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _allHistory
          .where((item) =>
              item.title.toLowerCase().contains(query) ||
              item.lastMessage.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _deleteHistory(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Chat', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this conversation?', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.deleteChat(id);
      _loadHistory();
    }
  }

  void _renameHistory(ChatHistory item) {
    final controller = TextEditingController(text: item.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Rename Chat", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          autofocus: true,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600))
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _historyService.updateChatTitle(item.id, controller.text.trim());
                _loadHistory();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: AppColors.primary, fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: const PremiumAppBar(title: "Chat History"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: _buildSearchBar(isDark),
          ),
          Expanded(
            child: _allHistory.isEmpty
                ? const EmptyState(
                    icon: Icons.history_rounded,
                    title: "No history yet",
                    subtitle: "Your AI conversations will be saved here for quick access.",
                  )
                : _buildHistoryList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GlassContainer(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: "Search conversations...",
          hintStyle: TextStyle(
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        final chat = _filteredHistory[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryCard(context, chat, isDark),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, ChatHistory chat, bool isDark) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      onTap: () async {
        await Navigator.pushNamed(context, AppRoutes.chat, arguments: chat.id);
        _loadHistory();
      },
      child: Row(
        children: [
          const IconContainer(
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.primary,
            size: 20,
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
                const SizedBox(height: 4),
                Text(
                  chat.lastMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6),
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.4), size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (value) {
              if (value == 'rename') _renameHistory(chat);
              if (value == 'delete') _deleteHistory(chat.id);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: AppColors.error, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }
}
