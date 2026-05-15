import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

void main() async {
  final sharedKey = '7jsqM47lL5eIjhKgz9Qj';
  final secretKey = 'aRO15DGhZ9UloR0K4FFOyQO0UbjJJZpLgjJkbgvT';

  final now = DateTime.now().toUtc();
  final timestamp = '${now.toIso8601String().split('.')[0]}Z';

  final argsStr = jsonEncode({
    "command": "holdings_comparison",
    "filerid": 349, // Berkshire
    "q1id": 99,
    "q2id": 100,
    "limit": 5
  });

  final msg = '$argsStr\n$timestamp';
  final key = utf8.encode(secretKey);
  final bytes = utf8.encode(msg);
  final hmacSha1 = Hmac(sha1, key);
  final digest = hmacSha1.convert(bytes);
  final sig = base64Encode(digest.bytes).replaceAll('\n', '');

  final url = Uri.parse(
    'https://whalewisdom.com/shell/command.json?args=${Uri.encodeComponent(argsStr)}&api_shared_key=$sharedKey&api_sig=${Uri.encodeComponent(sig)}&timestamp=$timestamp'
  );

  final res = await http.get(url);
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
