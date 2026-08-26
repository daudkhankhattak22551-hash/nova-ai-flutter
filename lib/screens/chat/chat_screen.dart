import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../models/chat/chat_message.dart';
import '../../services/ai/groq_service.dart';
import '../../services/history/chat_history_service.dart';
import '../../services/settings/settings_service.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  const ChatScreen({super.key, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatHistoryService _historyService = ChatHistoryService();
  
  bool _isTyping = false;
  bool _showScrollButton = false;
  String? _currentChatId;
  StreamSubscription? _streamSubscription;
  http.Client? _activeClient;

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId;
    _loadChatHistory();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final bool isNearBottom = _scrollController.offset >= _scrollController.position.maxScrollExtent - 300;
      if (_showScrollButton == isNearBottom) {
        setState(() {
          _showScrollButton = !isNearBottom;
        });
      }
    }
  }

  void _loadChatHistory() {
    if (_currentChatId != null) {
      final chat = _historyService.getChat(_currentChatId!);
      if (chat != null) {
        setState(() {
          _messages.clear();
          _messages.addAll(chat.messages);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(immediate: true));
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _activeClient?.close();
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool immediate = false}) {
    if (_scrollController.hasClients) {
      if (immediate) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    }
  }

  void _stopGeneration() {
    _streamSubscription?.cancel();
    _activeClient?.close();
    _activeClient = null;
    if (mounted) {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<void> _sendMessage({String? textToUse}) async {
    final text = textToUse ?? _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    if (textToUse == null) {
      final userMessage = ChatMessage(text: text, isUser: true);
      setState(() {
        _messages.add(userMessage);
        _messageController.clear();
        _isTyping = true;
      });
      if (_currentChatId == null) {
        final newChat = await _historyService.createNewChat(text);
        _currentChatId = newChat.id;
      }
      await _historyService.saveMessage(_currentChatId!, userMessage);
    } else {
      setState(() => _isTyping = true);
    }

    _scrollToBottom();

    try {
      _activeClient = http.Client();
      final groqService = GroqService(client: _activeClient);
      
      String aiResponseText = "";
      final aiMessage = ChatMessage(text: "", isUser: false);
      setState(() {
        _messages.add(aiMessage);
      });
      final int aiMsgIndex = _messages.length - 1;

      _streamSubscription = groqService.streamMessage(text).listen(
        (chunk) {
          aiResponseText += chunk;
          if (mounted) {
            setState(() {
              _messages[aiMsgIndex] = ChatMessage(
                text: aiResponseText, 
                isUser: false, 
                timestamp: aiMessage.timestamp
              );
            });
            _scrollToBottom();
          }
        },
        onDone: () async {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _activeClient = null;
            });
            if (aiResponseText.isNotEmpty && !aiResponseText.startsWith("AI Error:")) {
              await _historyService.saveMessage(_currentChatId!, _messages[aiMsgIndex]);
            }
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _activeClient = null;
              _messages.removeAt(aiMsgIndex);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().contains("Network") 
                      ? "Connection lost. Please retry." 
                      : "Nova AI encountered an issue. Please try again."),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            });
          }
        },
      );
    } catch (e) {
      _stopGeneration();
    }
  }

  void _regenerateLastMessage() {
    if (_messages.isEmpty || _isTyping) return;
    
    String? lastUserPrompt;
    int lastAiIndex = -1;

    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser && lastUserPrompt == null) {
        lastUserPrompt = _messages[i].text;
      } else if (!_messages[i].isUser && lastAiIndex == -1) {
        lastAiIndex = i;
      }
      if (lastUserPrompt != null && lastAiIndex != -1) break;
    }

    if (lastUserPrompt != null) {
      setState(() {
        if (lastAiIndex != -1) {
          _messages.removeAt(lastAiIndex);
          if (_currentChatId != null) {
            _historyService.removeLastMessage(_currentChatId!);
          }
        }
      });
      _sendMessage(textToUse: lastUserPrompt);
    }
  }

  void _handleFeedback(int index, int feedback) async {
    if (_currentChatId != null) {
      await _historyService.updateMessageFeedback(_currentChatId!, index, feedback);
    }
  }

  void _clearChat() {
    if (_messages.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        title: const Text('Clear Chat?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
        content: const Text('All messages in this session will be permanently removed.', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontWeight: FontWeight.w600))
          ),
          TextButton(
            onPressed: () async {
              if (_currentChatId != null) {
                await _historyService.clearMessages(_currentChatId!);
                if (mounted) {
                  setState(() {
                    _messages.clear();
                  });
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _createNewChat() {
    setState(() {
      _currentChatId = null;
      _messages.clear();
      _isTyping = false;
      _stopGeneration();
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = SettingsService.isPremium;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: _buildAppBar(isDark, isPremium),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _messages.isEmpty ? _buildEmptyState(isDark) : _buildChatList(),
                ),
                if (_isTyping) const TypingIndicator(),
                _buildInputArea(isDark),
              ],
            ),
            if (_showScrollButton)
              Positioned(
                bottom: 120,
                right: 20,
                child: FloatingActionButton.small(
                  onPressed: () => _scrollToBottom(),
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  child: const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isPremium) {
    return PremiumAppBar(
      title: "Nova AI Chat",
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isPremium)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "PRO",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
          tooltip: "New Chat",
          onPressed: _createNewChat,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onSelected: (val) {
            if (val == 'clear') _clearChat();
            if (val == 'history') Navigator.pushNamed(context, AppRoutes.history);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'history', child: Text('History', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
            const PopupMenuItem(value: 'clear', child: Text('Clear Session', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.error))),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: 32),
            Text(
              "Start a Conversation",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontFamily: 'Poppins',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ask anything from complex coding\nproblems to creative writing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip("Explain quantum physics", isDark),
                _buildSuggestionChip("Write a formal email", isDark),
                _buildSuggestionChip("Plan a 3-day trip to Tokyo", isDark),
                _buildSuggestionChip("Code a Flutter UI", isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: _messages.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isLatestAi = !message.isUser && index == _messages.length - 1;
        return ChatBubble(
          key: ValueKey(message.timestamp.millisecondsSinceEpoch + index),
          message: message,
          isLatestAiMessage: isLatestAi,
          onRegenerate: isLatestAi ? _regenerateLastMessage : null,
          onFeedback: (val) => _handleFeedback(index, val),
        );
      },
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        border: Border(top: BorderSide(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.3))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.attach_file_rounded, color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.5), size: 24),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isTyping ? _stopGeneration : () => _sendMessage(),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isTyping ? Icons.stop_rounded : Icons.send_rounded, 
                color: Colors.white, 
                size: 20
              ),
            ),
          ),
        ],
      ),
    );
  }
}
