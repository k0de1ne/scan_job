import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  // Наш "секретный сахар". Вместо строки храним байты,
  // чтобы его не было видно в поиске по бинарнику.
  // scan-job-salt-2024 -> [115, 99, 97, 110, 45, 106, 111, 98, 45, 115, 97, 108, 116, 45, 50, 48, 50, 52]
  static const List<int> _rawSalt = [
    115, 99, 97, 110, 45, 106, 111, 98, 45, 115, 97, 108, 116, 45, 50, 48, 50, 52
  ];

  static String generateSignature(String deviceId) {
    final saltStr = String.fromCharCodes(_rawSalt);
    final bytes = utf8.encode('$deviceId$saltStr');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String getSaltForServer() {
     // Эта функция только для того чтобы вы могли скопировать соль на сервер
     return String.fromCharCodes(_rawSalt);
  }
}
