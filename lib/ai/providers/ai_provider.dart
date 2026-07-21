import 'package:flutter/foundation.dart';
import '../models/ai_chat_message.dart';
import '../services/ai_service.dart';

class AiProvider with ChangeNotifier {
  final List<AiChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentContext = 'general';
  String? _currentConversationId;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String get currentContext => _currentContext;

  Future<void> sendMessage(String text, {String context = 'general'}) async {
    _currentContext = context;
    _messages.add(AiChatMessage(role: 'user', content: text));
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AiService.chat(text, context: context);
      _currentConversationId = result['conversationId'];
      _messages.add(AiChatMessage(
        id: _currentConversationId ?? '',
        role: 'assistant',
        content: result['reply'] ?? 'I\'m not sure how to respond to that.',
      ));
    } catch (e) {
      _messages.add(AiChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _currentConversationId = null;
    notifyListeners();
  }

  void setContext(String context) {
    _currentContext = context;
  }
}
