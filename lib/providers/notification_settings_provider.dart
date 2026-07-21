import 'package:flutter/material.dart';
import '../models/notification_settings_model.dart';
import '../services/settings_service.dart';

class NotificationSettingsProvider with ChangeNotifier {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _discounts = true;
  bool _newProducts = false;
  bool _deliveryUpdates = true;
  bool _aiRecommendations = true;
  bool _chatMessages = true;
  bool _supportMessages = true;
  bool _securityAlerts = true;
  bool _accountActivity = true;
  String _sound = 'default';
  bool _vibration = true;
  bool _previews = true;
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';
  final bool _isLoading = false;
  String? _error;

  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;
  bool get discounts => _discounts;
  bool get newProducts => _newProducts;
  bool get deliveryUpdates => _deliveryUpdates;
  bool get aiRecommendations => _aiRecommendations;
  bool get chatMessages => _chatMessages;
  bool get supportMessages => _supportMessages;
  bool get securityAlerts => _securityAlerts;
  bool get accountActivity => _accountActivity;
  String get sound => _sound;
  bool get vibration => _vibration;
  bool get previews => _previews;
  bool get quietHoursEnabled => _quietHoursEnabled;
  String get quietHoursStart => _quietHoursStart;
  String get quietHoursEnd => _quietHoursEnd;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadFromSettings(NotificationSettingsModel n) {
    _orderUpdates = n.orderUpdates;
    _promotions = n.promotions;
    _discounts = n.discounts;
    _newProducts = n.newProducts;
    _deliveryUpdates = n.deliveryUpdates;
    _aiRecommendations = n.aiRecommendations;
    _chatMessages = n.chatMessages;
    _supportMessages = n.supportMessages;
    _securityAlerts = n.securityAlerts;
    _accountActivity = n.accountActivity;
    _sound = n.sound;
    _vibration = n.vibration;
    _previews = n.previews;
    _quietHoursEnabled = n.quietHoursEnabled;
    _quietHoursStart = n.quietHoursStart;
    _quietHoursEnd = n.quietHoursEnd;
    notifyListeners();
  }

  NotificationSettingsModel _buildModel() {
    return NotificationSettingsModel(
      orderUpdates: _orderUpdates,
      promotions: _promotions,
      discounts: _discounts,
      newProducts: _newProducts,
      deliveryUpdates: _deliveryUpdates,
      aiRecommendations: _aiRecommendations,
      chatMessages: _chatMessages,
      supportMessages: _supportMessages,
      securityAlerts: _securityAlerts,
      accountActivity: _accountActivity,
      sound: _sound,
      vibration: _vibration,
      previews: _previews,
      quietHoursEnabled: _quietHoursEnabled,
      quietHoursStart: _quietHoursStart,
      quietHoursEnd: _quietHoursEnd,
    );
  }

  Future<void> setOrderUpdates(bool v) async { _orderUpdates = v; _notifyAndSave(); }
  Future<void> setPromotions(bool v) async { _promotions = v; _notifyAndSave(); }
  Future<void> setDiscounts(bool v) async { _discounts = v; _notifyAndSave(); }
  Future<void> setNewProducts(bool v) async { _newProducts = v; _notifyAndSave(); }
  Future<void> setDeliveryUpdates(bool v) async { _deliveryUpdates = v; _notifyAndSave(); }
  Future<void> setAiRecommendations(bool v) async { _aiRecommendations = v; _notifyAndSave(); }
  Future<void> setChatMessages(bool v) async { _chatMessages = v; _notifyAndSave(); }
  Future<void> setSupportMessages(bool v) async { _supportMessages = v; _notifyAndSave(); }
  Future<void> setSecurityAlerts(bool v) async { _securityAlerts = v; _notifyAndSave(); }
  Future<void> setAccountActivity(bool v) async { _accountActivity = v; _notifyAndSave(); }
  Future<void> setSound(String v) async { _sound = v; _notifyAndSave(); }
  Future<void> setVibration(bool v) async { _vibration = v; _notifyAndSave(); }
  Future<void> setPreviews(bool v) async { _previews = v; _notifyAndSave(); }
  Future<void> setQuietHoursEnabled(bool v) async { _quietHoursEnabled = v; _notifyAndSave(); }
  Future<void> setQuietHoursStart(String v) async { _quietHoursStart = v; _notifyAndSave(); }
  Future<void> setQuietHoursEnd(String v) async { _quietHoursEnd = v; _notifyAndSave(); }

  void _notifyAndSave() {
    notifyListeners();
    _error = null;
    _save();
  }

  Future<void> _save() async {
    try {
      await SettingsService.updateNotifications(_buildModel());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
