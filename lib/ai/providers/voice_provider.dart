import 'package:flutter/foundation.dart';
import '../models/voice_command.dart';
import '../services/voice_service.dart';

class VoiceProvider with ChangeNotifier {
  bool _isListening = false;
  bool _isProcessing = false;
  VoiceCommand? _lastCommand;
  String? _error;

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  VoiceCommand? get lastCommand => _lastCommand;
  String? get error => _error;

  void setListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  Future<void> processCommand(String transcript) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      _lastCommand = await VoiceService.processCommand(transcript);
    } catch (e) {
      _error = e.toString();
      _lastCommand = VoiceCommand(response: 'Sorry, I couldn\'t process that. Please try again.');
    }

    _isProcessing = false;
    notifyListeners();
  }

  void clear() {
    _lastCommand = null;
    _error = null;
    notifyListeners();
  }
}
