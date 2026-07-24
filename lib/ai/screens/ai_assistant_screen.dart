import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_product_card.dart';
import '../widgets/typing_indicator.dart';
import 'ai_conversation_history_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  final String initialContext;

  const AiAssistantScreen({super.key, this.initialContext = 'general'});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    _Suggestion('🍳', 'Suggest a meal', 'cooking'),
    _Suggestion('🥗', 'Healthy options', 'cooking'),
    _Suggestion('💰', 'Budget meals', 'budget'),
    _Suggestion('🌶️', 'Something spicy', 'cooking'),
    _Suggestion('👨‍👩‍👧‍👦', 'Family dinner (4+)', 'cooking'),
    _Suggestion('⏱️', 'Quick & easy (< 20min)', 'cooking'),
    _Suggestion('📋', 'Weekly meal plan', 'cooking'),
    _Suggestion('📊', 'Nutrition info', 'nutrition'),
    _Suggestion('🛒', 'What\'s available?', 'shopping'),
    _Suggestion('🎂', 'Dessert ideas', 'cooking'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ai = context.read<AiProvider>();
      ai.setContext(widget.initialContext);
      if (ai.messages.isEmpty) {
        ai.loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    _focusNode.requestFocus();
    final ai = context.read<AiProvider>();
    await ai.sendMessage(text, context: ai.currentContext);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userName = context.watch<UserProvider>().firstName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          Expanded(child: _buildBody(l10n, userName)),
          _buildContextSwitcher(l10n),
          _buildInputBar(l10n),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.t('aiAssistant'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Consumer<AiProvider>(
            builder: (_, ai, _) {
              if (ai.isLoading) {
                return Text(l10n.t('thinking'), style: const TextStyle(fontSize: 11, color: Colors.white70));
              }
              return Text(l10n.t('aiSubtitle'), style: const TextStyle(fontSize: 11, color: Colors.white70));
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiConversationHistoryScreen()),
            );
          },
          tooltip: l10n.t('chatHistory'),
        ),
        IconButton(
          icon: const Icon(Icons.add_comment_outlined),
          onPressed: () => context.read<AiProvider>().clearMessages(),
          tooltip: l10n.t('newChat'),
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n, String userName) {
    return Consumer<AiProvider>(
      builder: (_, ai, _) {
        if (ai.messages.isEmpty) {
          return _buildWelcomeView(l10n, userName);
        }
        return _buildMessageList(ai, l10n);
      },
    );
  }

  Widget _buildWelcomeView(AppLocalizations l10n, String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${l10n.t('hello')} $userName! 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.t('aiWelcomeMessage'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.t('quickActions'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              return ActionChip(
                avatar: Text(s.emoji, style: const TextStyle(fontSize: 16)),
                label: Text(s.label, style: const TextStyle(fontSize: 13)),
                onPressed: () => _sendMessage(s.label),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _buildTipsSection(l10n),
        ],
      ),
    );
  }

  Widget _buildTipsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('aiTips'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),
        _buildTipItem(Icons.restaurant_menu, l10n.t('aiTip1')),
        _buildTipItem(Icons.attach_money, l10n.t('aiTip2')),
        _buildTipItem(Icons.local_fire_department, l10n.t('aiTip3')),
        _buildTipItem(Icons.shopping_cart, l10n.t('aiTip4')),
      ],
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildMessageList(AiProvider ai, AppLocalizations l10n) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: ai.messages.length + (ai.isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == ai.messages.length) {
          return const TypingIndicator(text: 'SpiceBot is thinking...');
        }
        final msg = ai.messages[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiMessageBubble(
              message: msg.content,
              isUser: msg.role == 'user',
              timestamp: msg.timestamp,
            ),
            if (msg.role == 'assistant' && msg.productName != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 4, bottom: 12),
                child: AiProductCard(
                  productId: msg.productId,
                  productName: msg.productName,
                  productPrice: msg.productPrice,
                  productImage: msg.productImage,
                ),
              ),
            if (msg.role == 'assistant' && msg.suggestedActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 40, bottom: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: msg.suggestedActions.map((action) {
                    return ActionChip(
                      label: Text(action, style: const TextStyle(fontSize: 11)),
                      onPressed: () => _sendMessage(action),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContextSwitcher(AppLocalizations l10n) {
    return Consumer<AiProvider>(
      builder: (_, ai, _) {
        return Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildContextChip(l10n.t('general'), 'general', ai),
              _buildContextChip(l10n.t('cookingAssistant'), 'cooking', ai),
              _buildContextChip(l10n.t('nutritionAdvisor'), 'nutrition', ai),
              _buildContextChip(l10n.t('budgetPlanner'), 'budget', ai),
              _buildContextChip(l10n.t('smartSearch'), 'shopping', ai),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextChip(String label, String contextVal, AiProvider ai) {
    final isActive = ai.currentContext == contextVal;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.white : AppColors.onSurface)),
        selected: isActive,
        onSelected: (_) => ai.setContext(contextVal),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: isActive ? AppColors.primary : AppColors.outlineVariant),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildInputBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.t('typeMessage'),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (v) => _sendMessage(v),
                ),
              ),
            ),
            Consumer<AiProvider>(
              builder: (_, ai, _) {
                return IconButton(
                  icon: ai.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: ai.isLoading ? null : () => _sendMessage(_controller.text),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestion {
  final String emoji;
  final String label;
  final String context;
  const _Suggestion(this.emoji, this.label, this.context);
}
