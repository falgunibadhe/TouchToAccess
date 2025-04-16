import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import 'utils/http_helper.dart';  // Assuming you have a custom HttpHelper class

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _isRegistering = false;

  // Generate a unique Fingerprint ID (this is not the actual fingerprint data)
  String _generateFingerprintId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  Future<void> _registerUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Step 1: Validate the fields are not empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and Password cannot be empty')),
      );
      return;
    }

    // Step 2: Authenticate user via fingerprint
    bool isAuthenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to register your fingerprint',
      options: AuthenticationOptions(biometricOnly: true),
    );

    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint authentication failed.')),
      );
      return;
    }

    // Step 3: Generate a unique fingerprint ID (this will be sent to the backend)
    String fingerprintId = _generateFingerprintId();

    // Step 4: Register the user by sending email, password, and fingerprint ID
    setState(() => _isRegistering = true);

    try {
      final result = await HttpHelper.post(
        'http://192.168.29.236:5000/register', // Replace with your backend URL
        {
          'email': email,
          'password': password,
          'fingerprint_id': fingerprintId,
        },
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration complete')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }

    setState(() => _isRegistering = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isRegistering
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _registerUser, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
