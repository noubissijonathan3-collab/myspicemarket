import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/ai_provider.dart';
import '../models/ai_conversation.dart';

class AiConversationHistoryScreen extends StatefulWidget {
  const AiConversationHistoryScreen({super.key});

  @override
  State<AiConversationHistoryScreen> createState() => _AiConversationHistoryScreenState();
}

class _AiConversationHistoryScreenState extends State<AiConversationHistoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('chatHistory')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: l10n.t('newChat'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          Expanded(child: _buildConversationList(l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: l10n.t('searchChats'),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(AppLocalizations l10n) {
    return Consumer<AiProvider>(
      builder: (_, provider, _) {
        if (provider.isLoadingConversations) {
          return const Center(child: CircularProgressIndicator());
        }

        var convos = provider.conversations;
        if (_searchQuery.isNotEmpty) {
          convos = convos.where((c) => c.displayTitle.toLowerCase().contains(_searchQuery)).toList();
        }

        if (convos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  l10n.t('noConversations'),
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('startNewChat'),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: convos.length,
          itemBuilder: (_, i) {
            final conv = convos[i];
            return _buildConversationTile(conv, l10n);
          },
        );
      },
    );
  }

  Widget _buildConversationTile(AiConversation conv, AppLocalizations l10n) {
    final timeAgo = _formatTimeAgo(conv.updatedAt);
    final contextLabel = _contextLabel(conv.context, l10n);

    return Dismissible(
      key: Key(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.t('deleteChat')),
            content: Text(l10n.t('deleteChatConfirm')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.t('cancel'))),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.t('delete')),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<AiProvider>().deleteConversation(conv.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_contextIcon(conv.context), color: AppColors.primary, size: 20),
          ),
          title: Text(
            conv.displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(contextLabel, style: TextStyle(fontSize: 10, color: AppColors.primary)),
                ),
                const SizedBox(width: 8),
                Text(timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          onTap: () {
            context.read<AiProvider>().loadConversation(conv.id);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _contextLabel(String context, AppLocalizations l10n) {
    switch (context) {
      case 'cooking': return l10n.t('cookingAssistant');
      case 'nutrition': return l10n.t('nutritionAdvisor');
      case 'budget': return l10n.t('budgetPlanner');
      case 'shopping': return l10n.t('smartSearch');
      default: return l10n.t('aiAssistant');
    }
  }

  IconData _contextIcon(String context) {
    switch (context) {
      case 'cooking': return Icons.restaurant;
      case 'nutrition': return Icons.local_fire_department;
      case 'budget': return Icons.account_balance_wallet;
      case 'shopping': return Icons.shopping_bag;
      default: return Icons.auto_awesome;
    }
  }
}
