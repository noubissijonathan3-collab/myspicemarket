import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../l10n/app_localizations.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/quick_reply_button.dart';

class AiAssistantScreen extends StatefulWidget {
  final String initialContext;

  const AiAssistantScreen({super.key, this.initialContext = 'general'});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _quickReplies = [
    'What can I cook with chicken and rice?',
    'Suggest a healthy breakfast',
    'I want something spicy',
    'Recommend a meal for 4 people',
    'What vegetarian options do you have?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiProvider>().setContext(widget.initialContext);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    await context.read<AiProvider>().sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.t('aiAssistant')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AiProvider>().clearMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final l10n = AppLocalizations.of(context);
    return Consumer<AiProvider>(
      builder: (_, provider, _) {
        if (provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 60, color: AppColors.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(l10n.t('askAI'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text(l10n.t('aiCanHelp'), style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == provider.messages.length) {
              return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            }
            final msg = provider.messages[i];
            return AiMessageBubble(
              message: msg.content,
              isUser: msg.role == 'user',
              timestamp: msg.timestamp,
            );
          },
        );
      },
    );
  }

  Widget _buildQuickReplies() {
    return Consumer<AiProvider>(
      builder: (_, provider, _) {
        if (provider.messages.isNotEmpty) return const SizedBox.shrink();
        return Container(
          height: 50,
          padding: const EdgeInsets.only(left: 12),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickReplies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => QuickReplyButton(
              label: _quickReplies[i],
              onTap: () => _sendMessage(_quickReplies[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    final l10n = AppLocalizations.of(context);
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
            IconButton(
              icon: Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
