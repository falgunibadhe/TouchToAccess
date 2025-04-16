import 'package:local_auth/local_auth.dart';

class FingerprintAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check if the device supports biometrics and if there are any enrolled biometrics
  Future<bool> canAuthenticate() async {
    bool canCheckBiometrics = await _auth.canCheckBiometrics;
    bool hasFingerprints = await _auth.getAvailableBiometrics().then((value) => value.isNotEmpty);
    return canCheckBiometrics && hasFingerprints;
  }

  // Start fingerprint authentication
  Future<bool> authenticate() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        options: AuthenticationOptions(biometricOnly: true),
      );
      return isAuthenticated;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Register fingerprint (i.e., through system settings)
  // Note: In Flutter, registering a fingerprint is done through the device settings, not via the app.
  Future<void> registerFingerprint() async {
    try {
      await _auth.authenticate(
        localizedReason: 'Please authenticate to register your fingerprint',
        options: AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      print('Error during fingerprint registration: $e');
    }
  }
}
