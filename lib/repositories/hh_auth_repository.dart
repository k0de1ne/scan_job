import 'dart:convert';
import 'package:http/http.dart' as http;

class HhAuthRepository {

  HhAuthRepository({
    this.baseUrl = const String.fromEnvironment(
      'HH_AUTH_BASE_URL',
      defaultValue: 'http://localhost:8000',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> loginPhone(String phone) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitCaptcha(String sessionId, String captchaText) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login/captcha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'captcha_text': captchaText,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitCode(String sessionId, String code) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login/code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'code': code,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStatus(String sessionId) async {
    final response = await _client.get(Uri.parse('$baseUrl/status/$sessionId'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
