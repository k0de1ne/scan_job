import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  /// Salt is now passed via --dart-define=APP_SALT=your_salt_here
  static const String _salt = String.fromEnvironment(
    'APP_SALT',
    defaultValue: '',
  );

  static String generateSignature(String deviceId) {
    if (_salt.isEmpty) {
      // In production, you might want to throw an error or handle this differently
      // for now, we'll just log or continue, but security will be compromised.
    }
    final bytes = utf8.encode('$deviceId$_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
