import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  static const String _salt = String.fromEnvironment(
    'APP_SALT',
    defaultValue: '',
  );

  static String generateSignature(String deviceId) {
    final bytes = utf8.encode('$deviceId$_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
