import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils/http_helper.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> _authenticateAndLogin(BuildContext context) async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication not available')),
      );
      return;
    }

    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        // Retrieve the saved fingerprint ID
        String? fingerprintId = await storage.read(key: 'fingerprint_id');

        if (fingerprintId != null) {
          // Send fingerprint ID to backend to validate the user
          final response = await HttpHelper().validateFingerprint(fingerprintId);

          if (response['success']) {
            // Proceed with login if the fingerprint is valid
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fingerprint authenticated')),
            );

            // TODO: Navigate to the home/dashboard page
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (_) => HomePage()),
            // );
          } else {
            // If the fingerprint is not valid
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid Fingerprint')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No fingerprint registered')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Login with Fingerprint"),
              onPressed: () => _authenticateAndLogin(context),
            ),
            TextButton(
              child: const Text("Don't have an account? Register"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
