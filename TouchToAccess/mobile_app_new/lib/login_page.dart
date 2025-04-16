import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';  // Add this import to fix StreamSubscription
import 'utils/http_helper.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // Remove FlutterWebAuth related code if no longer needed
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _authenticateAndLogin(BuildContext context) async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      _showMessage('Biometric authentication not available');
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

      if (!didAuthenticate) {
        _showMessage('Authentication Failed');
        return;
      }

      _showMessage('Fingerprint authenticated');

      String? fingerprintId = await storage.read(key: 'fingerprint_id');
      String? loginId = await storage.read(key: 'login_id');

      if (fingerprintId == null) {
        _showMessage('No fingerprint registered');
        return;
      }

      final fingerprintRes = await HttpHelper.validateFingerprint(fingerprintId);

      if (!fingerprintRes['success']) {
        _showMessage('Invalid Fingerprint');
        return;
      }

      if (loginId == null) {
        _showMessage('No pending login request found');
        return;
      }

      final approveRes = await HttpHelper.post(
        'http://localhost:5000/approve-login',
        {'loginId': loginId},
      );

      if (approveRes['success']) {
        _showMessage('Login Approved!');
        // Trigger success state here
      } else {
        _showMessage('Failed to approve login');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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
