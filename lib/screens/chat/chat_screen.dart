import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/chat_service.dart';
import '../../utils/colors.dart';
import '../call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String orderId;
  final String agentName;
  final String agentAvatar;
  final String agentId;
  final bool isReadOnly;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.orderId,
    this.agentName = 'Preparation Agent',
    this.agentAvatar = '',
    this.agentId = '',
    this.isReadOnly = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isLoading = true;
  Timer? _typingTimer;
  bool _otherTyping = false;
  String _otherName = '';
  bool _agentOnline = true;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ChatService.connect();
      ChatService.joinChat(widget.chatRoomId);
    });
  }

  void _setupListeners() {
    ChatService.onMessageReceived = (msg) {
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollToBottom();
    };

    ChatService.onTyping = (userId, fullName, isTyping) {
      if (!mounted) return;
      setState(() {
        _otherTyping = isTyping;
        _otherName = fullName;
      });
    };

    ChatService.onMessagesRead = (_) {
      if (!mounted) return;
      setState(() {
        for (final msg in _messages) {
          if (msg.senderRole == 'customer') msg.read = true;
        }
      });
    };

    ChatService.onUserOnline = (userId) {
      if (!mounted) return;
      setState(() => _agentOnline = true);
    };

    ChatService.onUserOffline = (userId) {
      if (!mounted) return;
      setState(() => _agentOnline = false);
    };
  }

  Future<void> _loadMessages() async {
    try {
      final msgs = await ChatService.getMessages(widget.chatRoomId);
      if (!mounted) return;
      setState(() {
        _messages.addAll(msgs);
        _isLoading = false;
      });
      _scrollToBottom();
      ChatService.markRead(widget.chatRoomId);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final connected = await ChatService.ensureConnected();
    if (!connected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection lost. Please try again.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final localMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${_messages.length}',
      chatRoomId: widget.chatRoomId,
      senderId: ChatService.currentUserId ?? '',
      senderRole: 'customer',
      message: text,
      type: 'text',
      fileUrl: '',
      read: false,
      createdAt: DateTime.now(),
    );

    setState(() => _messages.add(localMsg));
    _scrollToBottom();

    ChatService.sendMessage(chatRoomId: widget.chatRoomId, message: text);
    ChatService.sendTyping(widget.chatRoomId, false);
  }

  void _onTyping() {
    ChatService.sendTyping(widget.chatRoomId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      ChatService.sendTyping(widget.chatRoomId, false);
    });
  }

  @override
  void dispose() {
    ChatService.leaveChat(widget.chatRoomId);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (widget.isReadOnly) _buildReadOnlyBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          if (!widget.isReadOnly && _otherTyping) _buildTypingIndicator(),
          if (!widget.isReadOnly) _buildQuickReplies(),
          if (!widget.isReadOnly) _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text(
            'This chat is closed. Messages can no longer be sent.',
            style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final avatarUrl = widget.agentAvatar.isNotEmpty
        ? (widget.agentAvatar.startsWith('http') ? widget.agentAvatar : '${AppConfig.baseUrl}${widget.agentAvatar}')
        : null;

    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.agentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: _agentOnline ? Colors.greenAccent : Colors.grey),
                    SizedBox(width: 4),
                    Text(_agentOnline ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 20),
            onPressed: (widget.agentId.isNotEmpty && !widget.isReadOnly)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          targetUserId: widget.agentId,
                          targetName: widget.agentName,
                          orderId: widget.orderId,
                        ),
                      ),
                    );
                  }
                : null,
          ),
          IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No messages yet', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text(
            widget.isReadOnly
                ? 'This chat is no longer active'
                : 'Send a message to your ${widget.agentName}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.senderRole == 'customer';
    final time = TimeOfDay.fromDateTime(msg.createdAt);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (msg.type == 'image' && msg.fileUrl.isNotEmpty)
            _buildImageMessage(msg, isMe, timeStr)
          else
            _buildTextMessage(msg, isMe, timeStr),
        ],
      ),
    );
  }

  Widget _buildTextMessage(ChatMessage msg, bool isMe, String timeStr) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            msg.message,
            style: TextStyle(fontSize: 15, color: isMe ? Colors.white : AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeStr, style: TextStyle(fontSize: 11, color: isMe ? Colors.white60 : Colors.grey.shade500)),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  msg.read ? Icons.done_all : Icons.done,
                  size: 14,
                  color: msg.read ? const Color(0xFF4AE176) : Colors.white60,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage msg, bool isMe, String timeStr) {
    final fullUrl = msg.fileUrl.startsWith('http') ? msg.fileUrl : '${AppConfig.baseUrl}${msg.fileUrl}';
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(fullUrl, fit: BoxFit.cover, height: 180, width: double.infinity,
              loadingBuilder: (_, child, progress) => progress == null ? child : const Padding(
                padding: EdgeInsets.all(40), child: CircularProgressIndicator(strokeWidth: 2)),
              errorBuilder: (_, _, _) => Container(height: 180, color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
            ),
          ),
          const SizedBox(height: 4),
          Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text('$_otherName typing...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = [
      'Where is my order?',
      'How long will delivery take?',
      'Can I change the address?',
      'Thank you',
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(quickReplies[i], style: const TextStyle(fontSize: 12)),
          onPressed: () {
            _messageController.text = quickReplies[i];
          },
          backgroundColor: AppColors.surfaceContainerLow,
          side: BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildInputBar() {
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
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppColors.primary),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (_) => _onTyping(),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
