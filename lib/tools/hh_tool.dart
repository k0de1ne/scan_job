import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HhAuthService {
  static const String clientId =
      'HIOMIAS39CA9DICTA7JIO64LQKQJF5AGIK74G9ITJKLNEDAOH5FHS5G1JI7FOEGD';
  static const String clientSecret =
      'V9M870DE342BGHFRUJ5FTCGCUA1482AN0DI8C5TFI9ULMA89H10N60NOP8I4JMVS';
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 13; Galaxy A55) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36';
  static const String accountsKey = 'hh_accounts';
  static const String selectedAccountKey = 'hh_selected_account';
  static const String callbackUrlScheme = 'hhandroid';

  final http.Client _client = http.Client();

  Future<List<String>> getAccountIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return [];
    return accountsJson.map((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['id'] as String;
    }).toList();
  }

  Future<Map<String, dynamic>?> getAccountToken(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return null;
    for (final jsonStr in accountsJson) {
      final map = jsonDecode(jsonStr);
      if (map['id'] == id) return map['token'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<String?> authenticate() async {
    final authUrl =
        'https://hh.ru/oauth/authorize?client_id=$clientId&response_type=code';
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackUrlScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: true),
      );
      final uri = Uri.parse(result);
      return uri.queryParameters['code'];
    } catch (e) {
      debugPrint('HH Auth: Error during authenticate: $e');
      return null;
    }
  }

  Future<String?> exchangeCodeForToken(String code) async {
    try {
      final response = await _client.post(
        Uri.parse('https://hh.ru/oauth/token'),
        headers: {'User-Agent': userAgent},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'grant_type': 'authorization_code',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;

        final meResponse = await _client.get(
          Uri.parse('https://api.hh.ru/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'User-Agent': userAgent,
          },
        );

        if (meResponse.statusCode == 200) {
          final meData = jsonDecode(meResponse.body) as Map<String, dynamic>;
          final id = meData['id'].toString();
          await _saveAccount(id, data);
          return id;
        }
      }
    } catch (e) {
      debugPrint('HH Auth: Exception during token exchange: $e');
    }
    return null;
  }

  Future<void> _saveAccount(String id, Map<String, dynamic> tokenData) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accountsJson = prefs.getStringList(accountsKey) ?? [];
    final newAccount = jsonEncode({'id': id, 'token': tokenData});
    final index = accountsJson.indexWhere(
      (jsonStr) => jsonDecode(jsonStr)['id'] == id,
    );
    if (index != -1) {
      accountsJson[index] = newAccount;
    } else {
      accountsJson.add(newAccount);
    }
    await prefs.setStringList(accountsKey, accountsJson);
  }

  Future<void> removeAccount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return;
    accountsJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['id'] == id);
    await prefs.setStringList(accountsKey, accountsJson);
  }

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final token = await getAccountToken(id);
    if (token == null) return null;
    final response = await _client.get(
      Uri.parse('https://api.hh.ru/me'),
      headers: {
        'Authorization': 'Bearer ${token['access_token']}',
        'User-Agent': userAgent,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getResumes(String id) async {
    final token = await getAccountToken(id);
    if (token == null) return null;
    final response = await _client.get(
      Uri.parse('https://api.hh.ru/resumes/mine'),
      headers: {
        'Authorization': 'Bearer ${token['access_token']}',
        'User-Agent': userAgent,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('items')) {
        return (data['items'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    return null;
  }
}

class HhTool {
  HhTool._();
  static HhTool? _instance;
  static HhTool get instance => _instance ??= HhTool._();

  final HhAuthService _service = HhAuthService();
  String? _selectedAccountId;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final ids = await _service.getAccountIds();
    if (ids.isNotEmpty) {
      _selectedAccountId = ids.first;
    }
  }

  Future<String?> getSelectedAccountId() async {
    await _ensureInitialized();
    if (_selectedAccountId != null) {
      final ids = await _service.getAccountIds();
      if (ids.contains(_selectedAccountId)) {
        return _selectedAccountId;
      }
    }
    final ids = await _service.getAccountIds();
    if (ids.isNotEmpty) {
      _selectedAccountId = ids.first;
      return _selectedAccountId;
    }
    return null;
  }

  List<Map<String, dynamic>> getToolsSpec() {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'hh_login',
          'description':
              'Start HeadHunter OAuth login. Opens browser for authentication.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_get_profile',
          'description':
              'Get HeadHunter user profile for currently logged in account.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_get_resumes',
          'description':
              'Get list of resumes for currently logged in HeadHunter user.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_logout',
          'description': 'Logout from currently selected HeadHunter account.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_list_accounts',
          'description': 'List all logged in HeadHunter accounts.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_select_account',
          'description': 'Switch to a different logged in HeadHunter account.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'account_id': {
                'type': 'string',
                'description': 'Account ID to switch to',
              },
            },
            'required': ['account_id'],
          },
        },
      },
    ];
  }

  Future<String> executeTool(String name, Map<String, dynamic> args) async {
    switch (name) {
      case 'hh_login':
        return _login();
      case 'hh_get_profile':
        return _getProfile();
      case 'hh_get_resumes':
        return _getResumes();
      case 'hh_logout':
        return _logout();
      case 'hh_list_accounts':
        return _listAccounts();
      case 'hh_select_account':
        return _selectAccount(args['account_id'] as String);
      default:
        throw Exception('Unknown tool: $name');
    }
  }

  Future<String> _login() async {
    final code = await _service.authenticate();
    if (code == null) {
      throw Exception('Authorization cancelled or failed');
    }
    final id = await _service.exchangeCodeForToken(code);
    if (id == null) {
      throw Exception('Failed to exchange code for token');
    }
    _selectedAccountId = id;
    final profile = await _service.getProfile(id);
    return jsonEncode({
      'success': true,
      'id': id,
      'first_name': profile?['first_name'],
      'last_name': profile?['last_name'],
    });
  }

  Future<String> _getProfile() async {
    final id = await getSelectedAccountId();
    if (id == null) {
      throw Exception('No account logged in. Use hh_login first.');
    }
    final profile = await _service.getProfile(id);
    if (profile == null) {
      throw Exception('Failed to get profile');
    }
    return jsonEncode({
      'success': true,
      'id': profile['id'],
      'first_name': profile['first_name'],
      'last_name': profile['last_name'],
      'middle_name': profile['middle_name'],
      'email': profile['email'],
      'phone': profile['phone']?['number'],
      'alternate_url': profile['alternate_url'],
    });
  }

  Future<String> _getResumes() async {
    final id = await getSelectedAccountId();
    if (id == null) {
      throw Exception('No account logged in. Use hh_login first.');
    }
    final resumes = await _service.getResumes(id);
    if (resumes == null) {
      throw Exception('Failed to get resumes');
    }
    final items = resumes
        .map(
          (r) => {
            'id': r['id'],
            'title': r['title'],
            'status': r['status']?['name'],
            'updated_at': r['updated_at'],
            'url': r['alternate_url'],
          },
        )
        .toList();
    return jsonEncode({
      'success': true,
      'resumes': items,
      'count': items.length,
    });
  }

  Future<String> _logout() async {
    final id = await getSelectedAccountId();
    if (id == null) {
      return jsonEncode({'success': true, 'message': 'No account to logout'});
    }
    await _service.removeAccount(id);
    final ids = await _service.getAccountIds();
    _selectedAccountId = ids.isNotEmpty ? ids.first : null;
    return jsonEncode({'success': true, 'message': 'Successfully logged out'});
  }

  Future<String> _listAccounts() async {
    final ids = await _service.getAccountIds();
    return jsonEncode({
      'success': true,
      'accounts': ids.cast<String>(),
      'selected_id': _selectedAccountId,
    });
  }

  Future<String> _selectAccount(String id) async {
    final ids = await _service.getAccountIds();
    if (!ids.contains(id)) {
      throw Exception('Account not found: $id');
    }
    _selectedAccountId = id;
    return jsonEncode({'success': true, 'message': 'Switched to account: $id'});
  }
}
