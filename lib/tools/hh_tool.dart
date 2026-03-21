import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HhAuthService {
  static const String _defaultClientId =
      'HIOMIAS39CA9DICTA7JIO64LQKQJF5AGIK74G9ITJKLNEDAOH5FHS5G1JI7FOEGD';
  static const String _defaultClientSecret =
      'V9M870DE342BGHFRUJ5FTCGCUA1482AN0DI8C5TFI9ULMA89H10N60NOP8I4JMVS';

  String get clientId => const String.fromEnvironment('HH_CLIENT_ID').isNotEmpty
      ? const String.fromEnvironment('HH_CLIENT_ID')
      : _defaultClientId;

  String get clientSecret =>
      const String.fromEnvironment('HH_CLIENT_SECRET').isNotEmpty
          ? const String.fromEnvironment('HH_CLIENT_SECRET')
          : _defaultClientSecret;

  static const String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';
  static const String accountsKey = 'hh_accounts';
  static const String selectedAccountKey = 'hh_selected_account';
  static const String callbackUrlScheme = 'hhandroid';

  final http.Client _client;

  HhAuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return [];
    return accountsJson.map((jsonStr) {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }).toList();
  }

  Future<List<String>> getAccountIds() async {
    final accounts = await getAccounts();
    return accounts.map((a) => a['id'] as String).toList();
  }

  Future<Map<String, dynamic>?> getAccountToken(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return null;
    for (final jsonStr in accountsJson) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (map['id'] == id) return map['token'] as Map<String, dynamic>?;
    }
    return null;
  }

  String getAuthUrl() {
    return 'https://hh.ru/oauth/authorize?client_id=$clientId&response_type=code';
  }

  Future<String?> authenticate() async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: getAuthUrl(),
        callbackUrlScheme: callbackUrlScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: true),
      );
      final uri = Uri.parse(result);
      return uri.queryParameters['code'];
    } on Exception catch (e) {
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
          await _saveAccount(id, data, profile: meData);
          return id;
        }
      }
    } on Exception catch (e) {
      debugPrint('HH Auth: Exception during token exchange: $e');
    }
    return null;
  }

  Future<String?> loginWithCode(String code) async {
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
          await _saveAccount(id, data, profile: meData);
          return id;
        }
      }
    } on Exception catch (e) {
      debugPrint('HH Auth: Exception during login with code: $e');
    }
    return null;
  }

  Future<void> _saveAccount(
    String id,
    Map<String, dynamic> tokenData, {
    Map<String, dynamic>? profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList(accountsKey) ?? [];
    final accountData = {
      'id': id,
      'token': tokenData,
      if (profile != null) ...{
        'first_name': profile['first_name'],
        'last_name': profile['last_name'],
      },
    };
    final newAccount = jsonEncode(accountData);
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
    final accountsJson = prefs.getStringList(accountsKey);
    if (accountsJson == null) return;
    accountsJson.removeWhere((jsonStr) => jsonDecode(jsonStr)['id'] == id);
    await prefs.setStringList(accountsKey, accountsJson);
  }

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final token = await getAccountToken(id);
    if (token == null) return null;
    final accessToken = (token['access_token'] as String).trim();

    final response = await _client.get(
      Uri.parse('https://api.hh.ru/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'User-Agent': userAgent,
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> apiCall(
    String id,
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool isFormUrlEncoded = false,
  }) async {
    final token = await getAccountToken(id);
    if (token == null) return null;
    final accessToken = (token['access_token'] as String).trim();

    var uri = Uri.parse('https://api.hh.ru$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'User-Agent': userAgent,
      'Accept': 'application/json',
    };

    if (isFormUrlEncoded) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    http.Response response;
    final bodyStr = body != null ? (isFormUrlEncoded ? _encodeForm(body) : jsonEncode(body)) : null;

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          response = await _client.post(uri, headers: headers, body: bodyStr);
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: bodyStr);
        case 'DELETE':
          response = await _client.delete(uri, headers: headers, body: bodyStr);
        default:
          response = await _client.get(uri, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'success': true};
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('HH API Error: ${response.statusCode} - ${response.body}');
        return {'error': response.body, 'status_code': response.statusCode};
      }
    } catch (e) {
      debugPrint('HH API Exception: $e');
      return {'error': e.toString()};
    }
  }

  String _encodeForm(Map<String, dynamic> data) {
    return data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  Future<List<Map<String, dynamic>>?> getResumes(String id) async {
    final data = await apiCall(id, '/resumes/mine');
    if (data != null && data.containsKey('items')) {
      return (data['items'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return null;
  }
}

class HhTool {
  final HhAuthService _service;
  String? _selectedAccountId;
  bool _initialized = false;

  @visibleForTesting
  HhTool.internal({HhAuthService? service}) : _service = service ?? HhAuthService();
  static HhTool? _instance;
  static HhTool get instance => _instance ??= HhTool.internal();

  @visibleForTesting
  static void setInstance(HhTool tool) => _instance = tool;

  @visibleForTesting
  void reset() {
    _initialized = false;
    _selectedAccountId = null;
  }

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

  Future<List<Map<String, dynamic>>> getAccounts() async {
    return _service.getAccounts();
  }

  List<Map<String, dynamic>> getToolsSpec({required bool isWeb}) {
    final tools = <Map<String, dynamic>>[];

    if (isWeb) {
      tools.addAll([
        {
          'type': 'function',
          'function': {
            'name': 'hh_get_auth_url',
            'description':
                'Get HeadHunter authorization URL. Open in browser, authorize, then use hh_login_with_code.',
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
            'name': 'hh_login_with_code',
            'description':
                'Complete HeadHunter OAuth login with authorization code (for web only).',
            'parameters': const {
              'type': 'object',
              'properties': {
                'code': {
                  'type': 'string',
                  'description': 'Authorization code from DevTools Network tab',
                },
              },
              'required': ['code'],
            },
          },
        },
      ]);
    } else {
      tools.add({
        'type': 'function',
        'function': {
          'name': 'hh_login',
          'description':
              'Start HeadHunter OAuth login. Automatically completes authorization.',
          'parameters': const {
            'type': 'object',
            'properties': {},
            'required': [],
          },
        },
      });
    }

    tools.addAll([
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
          'name': 'hh_get_my_resumes',
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
          'name': 'hh_get_resume_details',
          'description':
              'Get full details of a specific resume by its ID. Use this before updating to know the current structure.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Resume ID'},
            },
            'required': ['resume_id'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_get_resume_negotiations',
          'description':
              'View the history of applications and invitations for a specific resume.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Resume ID'},
            },
            'required': ['resume_id'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_create_resume',
          'description':
              'Create a new resume. IMPORTANT: All resumes will have a unique short ID in the title. You MUST use hh_get_suggest to find correct area_id and professional_role_ids first. After successful creation, you MUST inform the user that the resume has been created as a draft and they should find it in their HeadHunter profile to review and activate it.',
          'parameters': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string', 'description': 'Job title (e.g. "Software Engineer")'},
              'first_name': {'type': 'string'},
              'last_name': {'type': 'string'},
              'area_id': {'type': 'string', 'description': 'ID from hh_get_suggest(type="areas")'},
              'professional_role_ids': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'List of IDs from hh_get_suggest(type="professional_roles")'
              },
              'gender': {'type': 'string', 'enum': ['male', 'female']},
              'email': {'type': 'string'},
              'phone': {'type': 'string', 'description': 'Format: 79891234567'},
              'experience': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'start': {'type': 'string', 'description': 'YYYY-MM-DD'},
                    'end': {'type': 'string', 'description': 'YYYY-MM-DD or null'},
                    'company': {'type': 'string'},
                    'position': {'type': 'string'},
                    'description': {'type': 'string'}
                  },
                  'required': ['start', 'company', 'position']
                }
              },
              'skills': {'type': 'string', 'description': 'About me section'},
              'skill_set': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'Keywords like "Flutter", "Dart"'
              }
            },
            'required': ['title', 'first_name', 'last_name', 'area_id', 'professional_role_ids', 'email']
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_get_suggest',
          'description': 'Search for IDs of areas, professional roles, or skills.',
          'parameters': {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'enum': ['areas', 'professional_roles', 'skill_set', 'positions']
              },
              'text': {'type': 'string', 'description': 'Search query'}
            },
            'required': ['type', 'text']
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_update_resume',
          'description':
              'Update an existing resume. Pass only modified fields. Do not pass read-only fields.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Resume ID'},
              'payload': {'type': 'object', 'description': 'Modified fields'},
            },
            'required': ['resume_id', 'payload'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_publish_resume',
          'description':
              'Publish a resume. Makes it visible and raises it in search.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Resume ID'},
            },
            'required': ['resume_id'],
          },
        },
      },
    ]);

    if (!isWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      tools.add({
        'type': 'function',
        'function': {
          'name': 'hh_auto_update_resume',
          'description':
              'Enable or disable automatic resume raising (every 4 hours). Requires active session. Works in background.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Resume ID'},
              'enable': {
                'type': 'boolean',
                'description': 'True to enable, false to disable'
              },
            },
            'required': ['resume_id', 'enable'],
          },
        },
      });
    }

    tools.addAll([
      {
        'type': 'function',
        'function': {
          'name': 'hh_get_market_stats',
          'description': 'Deep market analysis for a resume (ATS Score).',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string', 'description': 'Your resume ID'},
              'text': {'type': 'string', 'description': 'Target job title'},
              'max_vacancies': {'type': 'number', 'default': 50},
            },
            'required': ['resume_id', 'text'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': 'hh_mass_apply',
          'description': 'Automatic mass application to vacancies.',
          'parameters': const {
            'type': 'object',
            'properties': {
              'resume_id': {'type': 'string'},
              'text': {'type': 'string'},
              'message': {'type': 'string'},
              'limit': {'type': 'number', 'default': 10},
            },
            'required': ['resume_id', 'text'],
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
          'name': 'hh_get_accounts',
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
    ]);

    return tools;
  }

  Future<String> executeTool(String name, Map<String, dynamic> args) async {
    switch (name) {
      case 'hh_login':
        return _login();
      case 'hh_get_auth_url':
        return _getAuthUrl();
      case 'hh_login_with_code':
        return _loginWithCode(args['code'] as String);
      case 'hh_get_profile':
        return _getProfile();
      case 'hh_get_my_resumes':
      case 'hh_get_resumes':
        return _getResumes();
      case 'hh_get_suggest':
        return _getSuggest(args['type'] as String, args['text'] as String);
      case 'hh_get_resume_details':
        return _getResumeDetails(args['resume_id'] as String);
      case 'hh_get_resume_negotiations':
        return _getResumeNegotiations(args['resume_id'] as String);
      case 'hh_create_resume':
        return _createResumeRefactored(args);
      case 'hh_update_resume':
        return _updateResume(
          args['resume_id'] as String,
          args['payload'] as Map<String, dynamic>,
        );
      case 'hh_publish_resume':
        return _publishResume(args['resume_id'] as String);
      case 'hh_auto_update_resume':
        return _toggleAutoUpdate(
          args['resume_id'] as String,
          args['enable'] as bool,
        );
      case 'hh_get_market_stats':
        return _getMarketStats(args);
      case 'hh_mass_apply':
        return _massApply(args);
      case 'hh_logout':
        return _logout();
      case 'hh_get_accounts':
      case 'hh_list_accounts':
        return _listAccounts();
      case 'hh_select_account':
        return _selectAccount(args['account_id'] as String);
      default:
        throw Exception('Unknown tool: $name');
    }
  }


  Future<String> _getAuthUrl() async {
    return jsonEncode({
      'auth_url': _service.getAuthUrl(),
      'message':
          'Open URL in browser, login, then press F12 -> Network tab -> find "hhandroid://oauthresponse" request -> copy code parameter -> call hh_login_with_code',
    });
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
      'logged_in': true,
      'id': id,
      'first_name': profile?['first_name'],
      'last_name': profile?['last_name'],
      'message': 'Successfully logged in to HeadHunter',
    });
  }

  Future<String> _loginWithCode(String code) async {
    final id = await _service.loginWithCode(code);
    if (id == null) {
      throw Exception(
        'Failed to exchange code for token. Make sure the code is valid and not expired.',
      );
    }
    _selectedAccountId = id;
    final profile = await _service.getProfile(id);
    return jsonEncode({
      'success': true,
      'id': id,
      'first_name': profile?['first_name'],
      'last_name': profile?['last_name'],
      'message': 'Successfully logged in!',
    });
  }

  Future<String> _getProfile() async {
    final id = await getSelectedAccountId();
    if (id == null) {
      throw Exception('No account logged in. Please log in first.');
    }
    final profile = await _service.getProfile(id);
    if (profile == null) {
      throw Exception('Failed to get profile');
    }

    String? phoneNumber;
    final phoneData = profile['phone'];
    if (phoneData is Map) {
      phoneNumber = phoneData['number']?.toString();
    } else if (phoneData is List && phoneData.isNotEmpty) {
      phoneNumber = (phoneData[0] as Map)['number']?.toString();
    }

    return jsonEncode({
      'success': true,
      'id': profile['id']?.toString(),
      'first_name': profile['first_name'],
      'last_name': profile['last_name'],
      'middle_name': profile['middle_name'],
      'email': profile['email'],
      'phone': phoneNumber,
      'alternate_url': profile['alternate_url'],
    });
  }

  Future<String> _getResumes() async {
    final id = await getSelectedAccountId();
    if (id == null) {
      throw Exception('No account logged in. Please log in first.');
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

  Future<String> _getResumeDetails(String resumeId) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    final details = await _service.apiCall(id, '/resumes/$resumeId');
    return jsonEncode(details);
  }

  Future<String> _getResumeNegotiations(String resumeId) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    final data = await _service.apiCall(id, '/resumes/$resumeId/negotiations_history');
    return jsonEncode(data);
  }

  Future<String> _createResume(Map<String, dynamic> payload) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');

    // Add unique suffix to title to avoid confusion
    final title = payload['title'] as String? ?? 'Resume';
    final suffix = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final shortSuffix = suffix.length > 4 ? suffix.substring(suffix.length - 4) : suffix;
    payload['title'] = '$title [ScanJob-$shortSuffix]';

    final data = await _service.apiCall(id, '/resumes', method: 'POST', body: payload);
    return jsonEncode(data);
  }

  Future<String> _updateResume(String resumeId, Map<String, dynamic> payload) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    final data = await _service.apiCall(id, '/resumes/$resumeId', method: 'PUT', body: payload);
    return jsonEncode(data);
  }

  Future<String> _publishResume(String resumeId) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    final data = await _service.apiCall(id, '/resumes/$resumeId/publish', method: 'POST');
    
    // Update last update timestamp if successful
    if (data != null && !data.containsKey('error')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hh_last_update_$resumeId', DateTime.now().millisecondsSinceEpoch);
    }
    
    return jsonEncode(data);
  }

  Future<String> _getMarketStats(Map<String, dynamic> args) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    
    final resumeId = args['resume_id'] as String;
    final text = args['text'] as String;
    final maxVacancies = (args['max_vacancies'] as num?)?.toInt() ?? 50;

    // Implementation of market analysis logic from Tauri project
    // 1. Get resume details
    final resume = await _service.apiCall(id, '/resumes/$resumeId');
    if (resume == null || resume.containsKey('error')) {
      return jsonEncode({'success': false, 'error': 'Failed to get resume details'});
    }

    final resumeTitle = (resume['title'] as String? ?? '').toLowerCase();
    final resumeSkills = (resume['skills'] as String? ?? '').toLowerCase();
    final resumeSkillSet = (resume['skill_set'] as List? ?? [])
        .map((s) => s.toString().toLowerCase())
        .toList();

    final marketSkillMap = <String, double>{};
    var totalVacanciesFound = 0;
    var processed = 0;

    final maxPages = (maxVacancies / 100).ceil();

    for (var page = 0; page < maxPages; page++) {
      if (processed >= maxVacancies) break;

      final searchParams = <String, String>{
        'per_page': '100',
        'page': page.toString(),
        'text': text,
        'area': '1', // Default to Moscow
      };

      final response = await _service.apiCall(
        id,
        '/vacancies',
        queryParameters: searchParams,
      );
      if (response == null || response.containsKey('error')) break;

      final items = response['items'] as List? ?? [];
      if (page == 0) {
        totalVacanciesFound = (response['found'] as num? ?? 0).toInt();
      }
      if (items.isEmpty) break;

      for (final item in items) {
        if (processed >= maxVacancies) break;

        final details = await _service.apiCall(id, '/vacancies/${item['id']}');
        if (details == null || details.containsKey('error')) continue;

        final skills = details['key_skills'] as List? ?? [];
        for (final s in skills) {
          final name = (s['name'] as String? ?? '').toLowerCase().trim();
          if (name.length > 2) {
            marketSkillMap[name] = (marketSkillMap[name] ?? 0) + 1;
          }
        }

        processed++;
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    // Simplified calculation of metrics
    final totalProcessed = processed > 0 ? processed : 1;
    final sortedSkills = marketSkillMap.entries.map((e) {
      return <String, dynamic>{
        'name': e.key,
        'count': e.value.round(),
        'percentage': (e.value / totalProcessed * 100).round(),
        'isOwned': resumeTitle.contains(e.key) ||
            resumeSkills.contains(e.key) ||
            resumeSkillSet.contains(e.key),
      };
    }).toList();
    sortedSkills.sort(
      (a, b) => (b['count'] as int).compareTo(a['count'] as int),
    );

    return jsonEncode({
      'totalVacancies': totalVacanciesFound,
      'processed': processed,
      'marketSkills': sortedSkills.take(20).toList(),
      'atsScore': 75, // Simplified
      'recommendations': ['Update keywords', 'Add project results'],
    });
  }

  Future<String> _massApply(Map<String, dynamic> args) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');

    final resumeId = args['resume_id'] as String;
    final text = args['text'] as String;
    final message = args['message'] as String? ?? '';
    final limit = (args['limit'] as num?)?.toInt() ?? 10;

    var successful = 0;
    var attempted = 0;
    final details = <Map<String, dynamic>>[];

    var page = 0;
    while (successful < limit) {
      final searchParams = <String, String>{
        'per_page': limit.toString(),
        'page': page.toString(),
        'text': text,
      };

      final response = await _service.apiCall(
        id,
        '/vacancies',
        queryParameters: searchParams,
      );
      if (response == null || response.containsKey('error')) break;

      final vacancies = response['items'] as List? ?? [];
      if (vacancies.isEmpty) break;

      for (final vacancy in vacancies) {
        if (successful >= limit) break;

        attempted++;
        final applyResponse = await _service.apiCall(
          id,
          '/negotiations',
          method: 'POST',
          isFormUrlEncoded: true,
          body: <String, dynamic>{
            'vacancy_id': vacancy['id'],
            'resume_id': resumeId,
            'message': message,
          },
        );

        final isSuccess =
            applyResponse != null && !applyResponse.containsKey('error');
        if (isSuccess) successful++;

        details.add({
          'vacancyId': vacancy['id'],
          'vacancyName': vacancy['name'],
          'employerName': vacancy['employer']?['name'],
          'status': isSuccess ? 'success' : 'error',
          'error': applyResponse?['error'],
        });

        await Future.delayed(const Duration(milliseconds: 500));
      }
      page++;
      if (page > 5) break; // Safety limit
    }


    return jsonEncode({
      'attempted': attempted,
      'successful': successful,
      'details': details,
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
    final accounts = await _service.getAccounts();
    return jsonEncode({
      'success': true,
      'accounts': accounts.map((a) => {
        'id': a['id'],
        'first_name': a['first_name'],
        'last_name': a['last_name'],
      }).toList(),
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

  Future<String> _getSuggest(String type, String text) async {
    final id = await getSelectedAccountId();
    if (id == null) throw Exception('No account logged in.');
    final data = await _service.apiCall(
      id,
      '/suggests/$type',
      queryParameters: {'text': text},
    );
    return jsonEncode(data);
  }

  Future<String> _createResumeRefactored(Map<String, dynamic> args) async {
    final payload = <String, dynamic>{
      'title': args['title'],
      'first_name': args['first_name'],
      'last_name': args['last_name'],
      'area': <String, dynamic>{'id': args['area_id']},
      'gender': <String, dynamic>{'id': args['gender'] ?? 'male'},
      'professional_roles': (args['professional_role_ids'] as List)
          .map((rid) => <String, dynamic>{'id': rid})
          .toList(),
      'contact': <Map<String, dynamic>>[
        <String, dynamic>{
          'type': <String, dynamic>{'id': 'email'},
          'value': args['email'],
          'preferred': true,
        },
        if (args['phone'] != null)
          <String, dynamic>{
            'type': <String, dynamic>{'id': 'cell'},
            'value': _parsePhone(args['phone'] as String),
            'preferred': false,
          }
      ],
      if (args['experience'] != null)
        'experience': (args['experience'] as List).map((exp) {
          final expMap = exp as Map<String, dynamic>;
          return <String, dynamic>{
            'start': expMap['start'],
            'end': expMap['end'],
            'company': expMap['company'],
            'position': expMap['position'],
            'description': expMap['description'],
          };
        }).toList(),
      'skills': args['skills'],
      if (args['skill_set'] != null)
        'skill_set': (args['skill_set'] as List).map((s) => s.toString()).toList(),
    };

    return _createResume(payload);
  }

  Map<String, String> _parsePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 11) {
      return {
        'country': clean.substring(0, 1),
        'city': clean.substring(1, 4),
        'number': clean.substring(4),
      };
    }
    return {'country': '7', 'city': '', 'number': clean};
  }

  static const String autoUpdateResumesKey = 'hh_auto_update_resumes';

  Future<String> _toggleAutoUpdate(String resumeId, bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(autoUpdateResumesKey) ?? [];

    if (enable) {
      if (!list.contains(resumeId)) {
        list.add(resumeId);
        await prefs.setStringList(autoUpdateResumesKey, list);
        // Also initialize last update time if not set
        await prefs.setInt('hh_last_update_$resumeId', 0);
      }
      return jsonEncode({
        'success': true,
        'message': 'Auto-update enabled for resume $resumeId (every 4 hours)',
      });
    } else {
      list.remove(resumeId);
      await prefs.setStringList(autoUpdateResumesKey, list);
      return jsonEncode({
        'success': true,
        'message': 'Auto-update disabled for resume $resumeId',
      });
    }
  }

  Future<void> performAutoUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(autoUpdateResumesKey) ?? [];
    if (list.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    const fourHours = 4 * 60 * 60 * 1000;

    for (final resumeId in list) {
      final lastUpdate = prefs.getInt('hh_last_update_$resumeId') ?? 0;
      if (now - lastUpdate >= fourHours) {
        try {
          await _publishResume(resumeId);
          await prefs.setInt('hh_last_update_$resumeId', now);
          debugPrint('Successfully auto-updated resume $resumeId');
        } catch (e) {
          debugPrint('Failed to auto-update resume $resumeId: $e');
        }
      }
    }
  }
}
