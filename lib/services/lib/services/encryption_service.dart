import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final _storage = FlutterSecureStorage();
  late final Key _key;
  late final IV _iv;

  Future<void> initialize() async {
    final keyString = await _storage.read(key: 'encryption_key') ??
        await _generateAndStoreKey();
    _key = Key.fromBase64(keyString);
    _iv = IV.fromLength(16);
  }

  Future<String> _generateAndStoreKey() async {
    final key = Key.fromSecureRandom(32);
    await _storage.write(key: 'encryption_key', value: key.base64);
    return key.base64;
  }

  String encryptMessage(String message) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.encrypt(message, iv: _iv).base64;
  }

  String decryptMessage(String encrypted) {
    final encrypter = Encrypter(AES(_key));
    return encrypter.decrypt64(encrypted, iv: _iv);
  }
}
