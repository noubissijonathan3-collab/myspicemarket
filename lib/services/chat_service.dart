import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderRole;
  final String message;
  final String type;
  final String fileUrl;
  bool read;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderRole,
    this.message = '',
    this.type = 'text',
    this.fileUrl = '',
    this.read = false,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['_id'] ?? json['id'] ?? '',
    chatRoomId: json['chatRoomId'] ?? '',
    senderId: json['senderId'] ?? '',
    senderRole: json['senderRole'] ?? 'customer',
    message: json['message'] ?? '',
    type: json['type'] ?? 'text',
    fileUrl: json['fileUrl'] ?? '',
    read: json['read'] ?? false,
    readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
  );
}

class ChatRoomData {
  final String id;
  final String orderId;
  final String customerId;
  final String? agentId;
  final String agentName;
  final String agentAvatar;
  final String agentType;
  final String status;

  ChatRoomData({
    required this.id,
    required this.orderId,
    required this.customerId,
    this.agentId,
    this.agentName = '',
    this.agentAvatar = '',
    this.agentType = 'preparation',
    this.status = 'active',
  });

  factory ChatRoomData.fromJson(Map<String, dynamic> json) => ChatRoomData(
    id: json['_id'] ?? json['id'] ?? '',
    orderId: json['orderId'] ?? '',
    customerId: json['customerId'] ?? '',
    agentId: json['agentId'],
    agentName: json['agentName'] ?? '',
    agentAvatar: json['agentAvatar'] ?? '',
    agentType: json['agentType'] ?? 'preparation',
    status: json['status'] ?? 'active',
  );
}

class ChatService {
  static const String _apiBase = '${AppConfig.baseUrl}/api/chat';
  static io.Socket? _socket;
  static String? _currentUserId;
  static String? _currentToken;

  static String? get currentUserId => _currentUserId;

  static void Function(ChatMessage message)? onMessageReceived;
  static void Function(String userId, String fullName, bool isTyping)? onTyping;
  static void Function(String userId)? onUserOnline;
  static void Function(String userId)? onUserOffline;
  static void Function(String userId)? onMessagesRead;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      final user = jsonDecode(data);
      return user['_id'] ?? user['id'] ?? '';
    }
    return null;
  }

  static Future<ChatRoomData?> getChatRoom(String orderId, {String agentType = 'preparation'}) async {
    final token = await _getToken();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('$_apiBase/room/$orderId?agentType=$agentType'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (res.statusCode == 200 && res.body != 'null') {
      return ChatRoomData.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<ChatRoomData> createChatRoom(String orderId, {String agentType = 'preparation'}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final res = await http.post(
      Uri.parse('$_apiBase/room'),
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
      body: jsonEncode({ 'orderId': orderId, 'agentType': agentType }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ChatRoomData.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create chat room');
  }

  static Future<List<ChatMessage>> getMessages(String chatRoomId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final res = await http.get(
      Uri.parse('$_apiBase/messages/$chatRoomId'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to load messages');
  }

  static Future<void>? _connectCompleter;
  static Future<void> connect() {
    if (_socket != null && _socket!.connected) {
      return _connectCompleter ??= Future<void>.value();
    }
    return _connectCompleter ??= _doConnect();
  }

  static Future<void> _doConnect() async {
    _currentToken = await _getToken();
    _currentUserId = await _getUserId();
    if (_currentToken == null || _currentUserId == null) return;
    if (_socket != null) {
      if (_socket!.connected) return;
      _socket!.disconnect();
      _socket = null;
    }

    _socket = io.io(AppConfig.baseUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({ 'token': _currentToken })
      .disableAutoConnect()
      .build());

    final connectFuture = Completer<void>();

    _socket!.on('connect', (_) {
      debugPrint('Socket connected: $_currentUserId');
      if (!connectFuture.isCompleted) connectFuture.complete();
    });

    _socket!.on('connect_error', (err) {
      debugPrint('Socket connect error: $err');
      _connectCompleter = null;
      if (!connectFuture.isCompleted) connectFuture.complete();
    });

    _socket!.on('new_message', (data) {
      final msg = ChatMessage.fromJson(data);
      debugPrint('New message received: ${msg.message}');
      if (msg.senderId != _currentUserId) {
        onMessageReceived?.call(msg);
      }
    });

    _socket!.on('user_typing', (data) {
      if (data['userId'] != _currentUserId) {
        onTyping?.call(data['userId'], data['fullName'] ?? '', data['isTyping'] ?? false);
      }
    });

    _socket!.on('user_online', (data) {
      onUserOnline?.call(data['userId']);
    });

    _socket!.on('user_offline', (data) {
      onUserOffline?.call(data['userId']);
    });

    _socket!.on('messages_read', (data) {
      onMessagesRead?.call(data['userId']);
    });

    _socket!.on('disconnect', (_) {
      debugPrint('Socket disconnected');
      _connectCompleter = null;
    });

    _socket!.connect();
    await connectFuture.future;
  }

  static Future<bool> ensureConnected() async {
    if (_socket != null && _socket!.connected) return true;
    try {
      await connect();
      return _socket != null && _socket!.connected;
    } catch (_) {
      return false;
    }
  }

  static void joinChat(String chatRoomId) {
    _socket?.emit('join_chat', { 'chatRoomId': chatRoomId });
  }

  static void leaveChat(String chatRoomId) {
    _socket?.emit('leave_chat', { 'chatRoomId': chatRoomId });
  }

  static void sendMessage({
    required String chatRoomId,
    required String message,
    String type = 'text',
    String fileUrl = '',
  }) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Socket not connected, cannot send message');
      return;
    }
    _socket?.emit('send_message', {
      'chatRoomId': chatRoomId,
      'message': message,
      'type': type,
      'fileUrl': fileUrl,
    });
  }

  static void sendTyping(String chatRoomId, bool isTyping) {
    _socket?.emit('typing', { 'chatRoomId': chatRoomId, 'isTyping': isTyping });
  }

  static void markRead(String chatRoomId) {
    _socket?.emit('mark_read', { 'chatRoomId': chatRoomId });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
