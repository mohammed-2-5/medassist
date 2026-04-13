import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-GCM encryption for backup files, with PBKDF2-HMAC-SHA256 key derivation.
class BackupCrypto {
  const BackupCrypto._();

  static const int _pbkdf2Iterations = 100000;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _keyBits = 256;

  /// Encrypt [plaintext] JSON with a key derived from [passphrase].
  /// Returns a JSON wrapper containing salt, nonce, ciphertext, and MAC.
  static Future<String> encryptJson({
    required String plaintext,
    required String passphrase,
  }) async {
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final secretKey = await _deriveKey(passphrase, salt);

    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final wrapper = <String, dynamic>{
      'version': 2,
      'encrypted': true,
      'kdf': 'pbkdf2-sha256',
      'iterations': _pbkdf2Iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
    return const JsonEncoder.withIndent('  ').convert(wrapper);
  }

  /// Decrypt a wrapper produced by [encryptJson]. Throws on wrong passphrase.
  static Future<String> decryptJson({
    required Map<String, dynamic> wrapper,
    required String passphrase,
  }) async {
    final salt = base64Decode(wrapper['salt'] as String);
    final nonce = base64Decode(wrapper['nonce'] as String);
    final ciphertext = base64Decode(wrapper['ciphertext'] as String);
    final mac = base64Decode(wrapper['mac'] as String);
    final iterations =
        wrapper['iterations'] as int? ?? _pbkdf2Iterations;

    final secretKey =
        await _deriveKey(passphrase, salt, iterations: iterations);
    final algorithm = AesGcm.with256bits();

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(mac),
    );
    final clear = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clear);
  }

  /// Whether a parsed backup JSON is an encrypted wrapper.
  static bool isEncrypted(Map<String, dynamic> json) {
    return json['encrypted'] == true;
  }

  static Future<SecretKey> _deriveKey(
    String passphrase,
    List<int> salt, {
    int iterations = _pbkdf2Iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: _keyBits,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }
}
