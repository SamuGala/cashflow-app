import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _pinKey = "app_pin";
  static const _biometricKey = "use_biometrics";

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null;
  }

  /// BIOMETRICS

  Future<void> enableBiometrics() async {
    await _storage.write(key: _biometricKey, value: "true");
  }

  Future<bool> biometricsEnabled() async {
    final value = await _storage.read(key: _biometricKey);
    return value == "true";
  }

  Future<void> disableBiometrics() async {
    await _storage.delete(key: _biometricKey);
  }
}
