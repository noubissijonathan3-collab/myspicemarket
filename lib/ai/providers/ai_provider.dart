import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ai_chat_message.dart';
import '../models/ai_conversation.dart';
import '../services/ai_service.dart';

class AiProvider with ChangeNotifier {
  final List<AiChatMessage> _messages = [];
  final List<AiConversation> _conversations = [];
  bool _isLoading = false;
  bool _isLoadingConversations = false;
  bool _isTyping = false;
  String _currentContext = 'general';
  String? _currentConversationId;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  List<AiConversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isTyping => _isTyping;
  String get currentContext => _currentContext;
  String? get currentConversationId => _currentConversationId;
  String? get error => _error;
  bool get hasConversations => _conversations.isNotEmpty;

  void setContext(String context) {
    _currentContext = context;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String context = 'general'}) async {
    if (text.trim().isEmpty) return;

    _currentContext = context;
    _error = null;
    _messages.add(AiChatMessage(role: 'user', content: text));
    _isLoading = true;
    _isTyping = true;
    _retryCount = 0;
    notifyListeners();

    await _sendWithRetry(text, context);
  }

  Future<void> _sendWithRetry(String text, String context) async {
    try {
      final result = await AiService.chat(text, context: context);
      _currentConversationId = result['conversationId'];

      final reply = result['reply'] ?? "I'm not sure how to respond to that.";
      final suggestedActions = List<String>.from(result['suggestedActions'] ?? []);

      _messages.add(AiChatMessage(
        id: _currentConversationId ?? '',
        role: 'assistant',
        content: reply,
        suggestedActions: suggestedActions,
        productId: result['productId'],
        productName: result['productName'],
        productPrice: result['productPrice']?.toDouble(),
        productImage: result['productImage'],
      ));
      _retryCount = 0;
    } catch (e) {
      _retryCount++;
      if (_retryCount <= _maxRetries) {
        final delay = Duration(seconds: _retryCount * 2);
        await Future.delayed(delay);
        if (_isLoading) {
          await _sendWithRetry(text, context);
          return;
        }
      }

      _messages.add(AiChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
      ));
      _error = e.toString();
    }

    _isLoading = false;
    _isTyping = false;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      final data = await AiService.getConversations();
      _conversations.clear();
      for (final conv in data) {
        _conversations.add(AiConversation.fromJson(conv));
      }
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }

    _isLoadingConversations = false;
    notifyListeners();
  }

  Future<void> loadConversation(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conv = await AiService.getConversation(id);
      _currentConversationId = id;
      _messages.clear();
      for (final msg in conv.messages) {
        _messages.add(msg);
      }
    } catch (e) {
      _error = 'Failed to load conversation';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    try {
      await AiService.deleteConversation(id);
      _conversations.removeWhere((c) => c.id == id);
      if (_currentConversationId == id) {
        clearMessages();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete conversation: $e');
    }
  }

  void clearMessages() {
    _messages.clear();
    _currentConversationId = null;
    _error = null;
    _retryCount = 0;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
