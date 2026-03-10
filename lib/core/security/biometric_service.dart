import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();

      if (!canCheck || !supported) {
        return false;
      }

      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final canUse = await canUseBiometrics();

      if (!canUse) {
        return false;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access Cashflow',
        biometricOnly: true,
      );

      return authenticated;
    } catch (_) {
      return false;
    }
  }
}
