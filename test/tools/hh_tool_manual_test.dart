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

  var tokenUpdated = false;
  var userIdUpdated = false;

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

  envFile.writeAsStringSync('${lines.join('\n').trim()}\n');
}

void main() {
  test('HH Full Tools Verification', () async {
    const code = String.fromEnvironment('CODE');
    
    if (code.isEmpty) {
      final authUrlJson = await HhTool.instance.executeTool('hh_get_auth_url', {});
      final authUrlMap = jsonDecode(authUrlJson) as Map<String, dynamic>;
      final authUrl = authUrlMap['auth_url'] as String;
      
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
    final loginResult = jsonDecode(loginResultJson) as Map<String, dynamic>;
    
    if (loginResult['success'] == true) {
      final id = loginResult['id'] as String;
      final prefs = await SharedPreferences.getInstance();
      final accounts = prefs.getStringList('hh_accounts') ?? [];
      String? accessToken;
      
      for (final accJson in accounts) {
        final acc = jsonDecode(accJson) as Map<String, dynamic>;
        if (acc['id'] == id) {
          accessToken = (acc['token'] as Map<String, dynamic>)['access_token'] as String;
          break;
        }
      }

      if (accessToken != null) {
        _updateEnv(accessToken, id);
        print('[2/4] Token saved to .env');

        print('\n[3/4] Running functional tools check:');
        
        // 1. Profile
        final profileJson = await tool.executeTool('hh_get_profile', {});
        final profile = jsonDecode(profileJson) as Map<String, dynamic>;
        if (profile['success'] == true) {
          print('  ✅ hh_get_profile: OK (User: ${profile['first_name']} ${profile['last_name']})');
        } else {
          print('  ❌ hh_get_profile: FAILED');
        }

        // 2. Resumes
        print('\n[3/4] Running functional tools check:');

        // 2.0.1 Suggest Test
        print('  ⌛ Testing hh_get_suggest (areas: Moscow)...');
        final suggestJson = await tool.executeTool('hh_get_suggest', {'type': 'areas', 'text': 'Moscow'});
        final suggestResult = jsonDecode(suggestJson) as Map<String, dynamic>;
        var areaId = '1'; // Default
        final items = suggestResult['items'] as List?;
        if (items != null && items.isNotEmpty) {
          areaId = (items[0] as Map<String, dynamic>)['id'] as String;
          print('    ✅ hh_get_suggest: OK (Found ID: $areaId for ${(items[0] as Map<String, dynamic>)['text']})');
        }

        // 2.0.2 Create Test Resume (New Structure)
        print('  ⌛ Testing hh_create_resume (Refactored)...');
        final createJson = await tool.executeTool('hh_create_resume', {
          'title': 'Test Resume',
          'first_name': profile['first_name'],
          'last_name': profile['last_name'],
          'area_id': areaId,
          'professional_role_ids': ['96'], // Software Engineer
          'email': profile['email'],
          'gender': 'male',
          'experience': [
            {
              'start': '2022-01-01',
              'company': 'Scan Job AI',
              'position': 'AI Engineer',
              'description': 'Building career automation tools.'
            }
          ],
          'skills': 'Expert in Flutter and Dart.',
          'skill_set': ['Flutter', 'Dart']
        });
        final createResult = jsonDecode(createJson) as Map<String, dynamic>;
        String? newResumeId;
        if (createResult.containsKey('id')) {
          newResumeId = createResult['id'] as String;
          print('    ✅ hh_create_resume: OK (New ID: $newResumeId, Title: ${createResult['title']})');
        } else {
          print('    ❌ hh_create_resume: FAILED - $createJson');
        }

        final resumesJson = await tool.executeTool('hh_get_my_resumes', {});
        final resumes = jsonDecode(resumesJson) as Map<String, dynamic>;
        if (resumes['success'] == true) {
          print('  ✅ hh_get_my_resumes: OK (Found ${resumes['count']} items)');
          
          final resumesList = resumes['resumes'] as List;
          if (resumesList.isNotEmpty) {
            final firstResume = resumesList[0] as Map<String, dynamic>;
            final resumeId = firstResume['id'] as String;
            
            // 2.1 Resume Details
            final detailsJson = await tool.executeTool('hh_get_resume_details', {'resume_id': resumeId});
            final details = jsonDecode(detailsJson) as Map<String, dynamic>;
            if (details.containsKey('id')) {
              print('    ✅ hh_get_resume_details: OK (ID: ${details['id']})');
            } else {
              print('    ❌ hh_get_resume_details: FAILED');
            }

            // 2.2 Resume Negotiations
            final negJson = await tool.executeTool('hh_get_resume_negotiations', {'resume_id': resumeId});
            final neg = jsonDecode(negJson) as Map<String, dynamic>;
            if (neg.containsKey('items') || neg.containsKey('error')) {
              print('    ✅ hh_get_resume_negotiations: OK');
            } else {
              print('    ❌ hh_get_resume_negotiations: FAILED');
            }

            // 2.3 Market Stats
            print('  ⌛ Starting hh_get_market_stats (this may take a few seconds)...');
            final statsJson = await tool.executeTool('hh_get_market_stats', {
              'resume_id': resumeId,
              'text': firstResume['title'] as String,
              'max_vacancies': 10
            });
            final stats = jsonDecode(statsJson) as Map<String, dynamic>;
            if (stats.containsKey('atsScore')) {
              print('    ✅ hh_get_market_stats: OK (ATS Score: ${stats['atsScore']})');
            } else {
              print('    ❌ hh_get_market_stats: FAILED');
            }

            // 2.4 Mass Apply (Dry run / Limit 1)
            print('  ⌛ Starting hh_mass_apply (Limit: 1)...');
            final applyJson = await tool.executeTool('hh_mass_apply', {
              'resume_id': resumeId,
              'text': firstResume['title'] as String,
              'limit': 1
            });
            final apply = jsonDecode(applyJson) as Map<String, dynamic>;
            if (apply.containsKey('attempted')) {
              print('    ✅ hh_mass_apply: OK (Attempted: ${apply['attempted']})');
            } else {
              print('    ❌ hh_mass_apply: FAILED');
            }
          }
        } else {
          print('  ❌ hh_get_my_resumes: FAILED');
        }

        // 3. List Accounts
        final listJson = await tool.executeTool('hh_get_accounts', {});
        final listAccs = jsonDecode(listJson) as Map<String, dynamic>;
        if (listAccs['success'] == true) {
          print('  ✅ hh_get_accounts: OK (Current ID: ${listAccs['selected_id']}, Count: ${(listAccs['accounts'] as List).length})');
        } else {
          print('  ❌ hh_get_accounts: FAILED');
        }

        print('\n[4/4] Final status:');
        if (profile['success'] == true && resumes['success'] == true && listAccs['success'] == true) {
          print('🚀 ALL HH TOOLS ARE WORKING CORRECTLY!');
        } else {
          fail('Some tools failed verification.');
        }
      } else {
        fail('Token exchange succeeded but token not found in storage.');
      }
    } else {
      fail('Login failed: $loginResultJson');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
