import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_job/tools/hh_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper to update .env file
void _updateEnv(String accessToken, String userId) {
  final envFile = File('.env');
  var lines = <String>[];
  if (envFile.existsSync()) {
    lines = envFile.readAsLinesSync();
  }

  bool tokenUpdated = false;
  bool userIdUpdated = false;

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('HH_ACCESS_TOKEN=')) {
      lines[i] = 'HH_ACCESS_TOKEN=$accessToken';
      tokenUpdated = true;
    }
    if (lines[i].trim().startsWith('HH_USER_ID=')) {
      lines[i] = 'HH_USER_ID=$userId';
      userIdUpdated = true;
    }
  }

  if (!tokenUpdated) lines.add('HH_ACCESS_TOKEN=$accessToken');
  if (!userIdUpdated) lines.add('HH_USER_ID=$userId');

  envFile.writeAsStringSync(lines.join('\n').trim() + '\n');
}

void main() {
  test('HH Full Tools Verification', () async {
    const code = String.fromEnvironment('CODE');
    
    if (code.isEmpty) {
      final authUrlJson = await HhTool.instance.executeTool('hh_get_auth_url', {});
      final authUrl = jsonDecode(authUrlJson)['auth_url'];
      
      print('\n=== HH TOOLS CHECKER ===');
      print('1. Get a code here: $authUrl');
      print('2. Run: flutter test test/tools/hh_tool_manual_test.dart --dart-define=CODE=ВАШ_КОД');
      print('========================\n');
      fail('CODE is missing');
    }

    SharedPreferences.setMockInitialValues({});
    final tool = HhTool.instance;
    tool.reset();

    print('\n[1/4] Exchanging code for token...');
    final loginResultJson = await tool.executeTool('hh_login_with_code', {'code': code});
    final loginResult = jsonDecode(loginResultJson);
    
    if (loginResult['success'] == true) {
      final id = loginResult['id'];
      final prefs = await SharedPreferences.getInstance();
      final accounts = prefs.getStringList('hh_accounts') ?? [];
      String? accessToken;
      
      for (final accJson in accounts) {
        final acc = jsonDecode(accJson);
        if (acc['id'] == id) {
          accessToken = acc['token']['access_token'];
          break;
        }
      }

      if (accessToken != null) {
        _updateEnv(accessToken, id);
        print('[2/4] Token saved to .env');

        print('\n[3/4] Running functional tools check:');
        
        // 1. Profile
        final profileJson = await tool.executeTool('hh_get_profile', {});
        final profile = jsonDecode(profileJson);
        if (profile['success'] == true) {
          print('  ✅ hh_get_profile: OK (User: ${profile['first_name']} ${profile['last_name']})');
        } else {
          print('  ❌ hh_get_profile: FAILED');
        }

        // 2. Resumes
        final resumesJson = await tool.executeTool('hh_get_resumes', {});
        final resumes = jsonDecode(resumesJson);
        if (resumes['success'] == true) {
          print('  ✅ hh_get_resumes: OK (Found ${resumes['count']} items)');
        } else {
          print('  ❌ hh_get_resumes: FAILED');
        }

        // 3. List Accounts
        final listJson = await tool.executeTool('hh_list_accounts', {});
        final listAccs = jsonDecode(listJson);
        if (listAccs['success'] == true) {
          print('  ✅ hh_list_accounts: OK (Current ID: ${listAccs['selected_id']})');
        } else {
          print('  ❌ hh_list_accounts: FAILED');
        }

        print('\n[4/4] Final status:');
        if (profile['success'] && resumes['success'] && listAccs['success']) {
          print('🚀 ALL HH TOOLS ARE WORKING CORRECTLY!');
        } else {
          fail('Some tools failed verification.');
        }
      } else {
        fail('Token exchange succeeded but token not found in storage.');
      }
    } else {
      fail('Login failed: ${loginResultJson}');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
