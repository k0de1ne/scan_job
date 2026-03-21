import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan_job/tools/hh_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHhAuthService extends Mock implements HhAuthService {}

void main() {
  group('HhTool Unit Tests', () {
    late MockHhAuthService mockService;
    late HhTool tool;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockService = MockHhAuthService();
      // Reset the singleton instance with a mock for testing
      tool = HhTool.instance; // This just gets the singleton
      // We use the new internal constructor or setInstance if available
      HhTool.setInstance(HhTool.testApi(service: mockService));
      tool = HhTool.instance;
    });

    test('hh_get_profile should return formatted profile data', () async {
      when(() => mockService.getAccountIds()).thenAnswer((_) async => ['user_123']);
      when(() => mockService.getProfile('user_123')).thenAnswer((_) async => {
            'id': 'user_123',
            'first_name': 'Ivan',
            'last_name': 'Ivanov',
            'email': 'ivan@example.com',
            'phone': {'number': '79991234567'},
            'alternate_url': 'https://hh.ru/resume/123'
          });

      final resultJson = await tool.executeTool('hh_get_profile', {});
      final result = jsonDecode(resultJson);

      expect(result['success'], isTrue);
      expect(result['first_name'], equals('Ivan'));
      expect(result['email'], equals('ivan@example.com'));
      verify(() => mockService.getProfile('user_123')).called(1);
    });

    test('hh_get_resumes should return list of items', () async {
      when(() => mockService.getAccountIds()).thenAnswer((_) async => ['user_123']);
      when(() => mockService.getResumes('user_123')).thenAnswer((_) async => [
            {
              'id': 'res_1',
              'title': 'Flutter Developer',
              'status': {'name': 'Published'},
              'updated_at': '2024-03-21T10:00:00',
              'alternate_url': 'https://hh.ru/res/1'
            }
          ]);

      final resultJson = await tool.executeTool('hh_get_resumes', {});
      final result = jsonDecode(resultJson);

      expect(result['success'], isTrue);
      expect(result['count'], equals(1));
      expect(result['resumes'][0]['title'], equals('Flutter Developer'));
    });

    test('hh_logout should clear session', () async {
      when(() => mockService.getAccountIds()).thenAnswer((_) async => ['user_123']);
      when(() => mockService.removeAccount('user_123')).thenAnswer((_) async => {});
      // After removal, list should be empty
      when(() => mockService.getAccountIds()).thenAnswer((_) async => []);

      final resultJson = await tool.executeTool('hh_logout', {});
      final result = jsonDecode(resultJson);

      expect(result['success'], isTrue);
      verify(() => mockService.removeAccount('user_123')).called(1);
    });
  });
}

// Extension to allow creating HhTool with a mock for testing if private constructor is used
extension HhToolTest on HhTool {
  static HhTool testApi({required HhAuthService service}) {
    // In lib/tools/hh_tool.dart I added a factory or adjusted constructor
    // I will adjust the lib to make this cleaner if needed.
    return HhTool.internal(service: service);
  }
}
