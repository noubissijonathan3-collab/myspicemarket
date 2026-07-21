import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/storage_settings_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class StorageProvider with ChangeNotifier {
  int _cacheSize = 0;
  bool _cacheImages = true;
  bool _wifiOnlyImages = false;
  bool _autoplayVideos = true;
  bool _cacheTranslations = true;
  int _downloadedBanners = 0;
  int _offlineTranslations = 0;
  bool _isLoading = false;
  String? _error;

  int get cacheSize => _cacheSize;
  bool get cacheImages => _cacheImages;
  bool get wifiOnlyImages => _wifiOnlyImages;
  bool get autoplayVideos => _autoplayVideos;
  bool get cacheTranslations => _cacheTranslations;
  int get downloadedBanners => _downloadedBanners;
  int get offlineTranslations => _offlineTranslations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get formattedCacheSize {
    if (_cacheSize < 1024) return '$_cacheSize B';
    if (_cacheSize < 1024 * 1024) return '${(_cacheSize / 1024).toStringAsFixed(1)} KB';
    if (_cacheSize < 1024 * 1024 * 1024) return '${(_cacheSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(_cacheSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void loadFromSettings(StorageSettingsModel s) {
    _cacheSize = s.cacheSize;
    _cacheImages = s.cacheImages;
    _wifiOnlyImages = s.wifiOnlyImages;
    _autoplayVideos = s.autoplayVideos;
    _cacheTranslations = s.cacheTranslations;
    _downloadedBanners = s.downloadedBanners;
    _offlineTranslations = s.offlineTranslations;
    notifyListeners();
  }

  Future<void> setCacheImages(bool v) async { _cacheImages = v; notifyListeners(); await _save(); }
  Future<void> setWifiOnlyImages(bool v) async { _wifiOnlyImages = v; notifyListeners(); await _save(); }
  Future<void> setAutoplayVideos(bool v) async { _autoplayVideos = v; notifyListeners(); await _save(); }
  Future<void> setCacheTranslations(bool v) async { _cacheTranslations = v; notifyListeners(); await _save(); }

  Future<void> _save() async {
    _error = null;
    try {
      final token = await AuthService.getToken();
      await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'storage': {
            'cacheSize': _cacheSize,
            'cacheImages': _cacheImages,
            'wifiOnlyImages': _wifiOnlyImages,
            'autoplayVideos': _autoplayVideos,
            'cacheTranslations': _cacheTranslations,
            'downloadedBanners': _downloadedBanners,
            'offlineTranslations': _offlineTranslations,
          }
        }),
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await StorageService.clearCache();
      _cacheSize = result['cacheSize'] as int? ?? 0;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await StorageService.clearDownloadedBanners();
      _downloadedBanners = 0;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearTranslations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await StorageService.clearOfflineTranslations();
      _offlineTranslations = 0;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
