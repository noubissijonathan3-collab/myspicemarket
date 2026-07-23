import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../models/voice_command.dart';

class VoiceService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/ai/voice';

  static Future<VoiceCommand> processCommand(String transcript) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.post(
      Uri.parse('$_baseUrl/process'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'transcript': transcript}),
    ).timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) return VoiceCommand.fromJson(jsonDecode(res.body));
    throw Exception('Voice processing failed');
  }
}
