import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../models/chat/chat_message.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;
  final bool isLatestAiMessage;
  final Function(int)? onFeedback; // 1: like, 2: dislike

  const ChatBubble({
    super.key,
    required this.message,
    this.onRegenerate,
    this.isLatestAiMessage = false,
    this.onFeedback,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late int _feedback;

  @override
  void initState() {
    super.initState();
    _feedback = widget.message.feedback;
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Copied to clipboard', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 110),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareMessage(String text) {
    Share.share(text, subject: 'Shared from Nova AI');
  }

  void _handleFeedback(int value) {
    setState(() {
      _feedback = (_feedback == value) ? 0 : value;
    });
    if (widget.onFeedback != null) {
      widget.onFeedback!(_feedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = widget.message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const IconContainer(
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 16,
                  padding: 8,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isUser ? const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        color: isUser ? null : (isDark ? AppColors.surfaceDark : AppColors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isUser ? 22 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUser 
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: !isUser ? Border.all(
                          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
                        ) : null,
                      ),
                      child: isUser 
                        ? Text(
                            widget.message.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          )
                        : MarkdownBody(
                            data: widget.message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                height: 1.6,
                              ),
                              code: TextStyle(
                                backgroundColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                              codeblockPadding: const EdgeInsets.all(0),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              h1: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              h2: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              h3: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              listBullet: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                            ),
                            builders: {
                              'code': CodeBlockBuilder(
                                isDark: isDark,
                                onCopy: (text) => _copyToClipboard(context, text),
                              ),
                            },
                          ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) const SizedBox(width: 8), 
            ],
          ),
          if (!isUser && widget.message.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildBubbleAction(Icons.copy_rounded, () => _copyToClipboard(context, widget.message.text), isDark),
                  _buildBubbleAction(
                    _feedback == 1 ? Icons.thumb_up_rounded : Icons.thumb_up_off_alt_rounded, 
                    () => _handleFeedback(1), 
                    isDark,
                    activeColor: AppColors.success,
                    isActive: _feedback == 1
                  ),
                  _buildBubbleAction(
                    _feedback == 2 ? Icons.thumb_down_rounded : Icons.thumb_down_off_alt_rounded, 
                    () => _handleFeedback(2), 
                    isDark,
                    activeColor: AppColors.error,
                    isActive: _feedback == 2
                  ),
                  _buildBubbleAction(Icons.share_rounded, () => _shareMessage(widget.message.text), isDark),
                  if (widget.isLatestAiMessage && widget.onRegenerate != null)
                    _buildBubbleAction(Icons.refresh_rounded, widget.onRegenerate!, isDark),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBubbleAction(IconData icon, VoidCallback onTap, bool isDark, {Color? activeColor, bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive 
            ? (activeColor ?? AppColors.primary).withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.white),
          border: Border.all(
            color: isActive 
              ? (activeColor ?? AppColors.primary).withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon, 
          size: 14, 
          color: isActive 
            ? (activeColor ?? AppColors.primary) 
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6)
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;
  final Function(String) onCopy;

  CodeBlockBuilder({required this.isDark, required this.onCopy});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final codeContent = element.textContent.trim();
    if (!element.textContent.contains('\n')) return null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CODE", 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Poppins')
                ),
                GestureDetector(
                  onTap: () => onCopy(codeContent),
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text(
                        "COPY", 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Poppins')
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                codeContent,
                style: TextStyle(
                  fontFamily: 'monospace', 
                  fontSize: 13,
                  color: isDark ? const Color(0xFFE2E2E7) : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
