import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Signup extends StatefulWidget {
  @override
  _Signup createState() => _Signup();
}

class _Signup extends State<Signup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _showVerification = false;
  bool _isVerifying = false;

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Basic validation
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showAlert('Error', 'Please fill out all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showAlert('Error', 'Passwords do not match.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showAlert('Error', 'Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(username, email, password);
      setState(() => _isLoading = false);

      if (response['success']) {
        // Store tokens if provided in response
        if (response['data'] != null && 
            response['data']['accessToken'] != null && 
            response['data']['refreshToken'] != null) {
          await ApiService.storeTokens(
            response['data']['accessToken'],
            response['data']['refreshToken'],
          );
        }
        
        setState(() => _showVerification = true);
        _showAlert('Success', 'Verification code sent to your email.');
      } else {
        _showAlert('Error', response['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Error', 'An error occurred. Please try again.');
    }
  }

  Future<void> _verifyEmail() async {
    String code = _verificationCodeController.text;
    String email = _emailController.text;

    if (code.isEmpty) {
      _showAlert('Error', 'Please enter the verification code.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await ApiService.verifyEmail(email, code);
      setState(() => _isVerifying = false);

      if (response['success']) {
        await ApiService.setUserVerified();
        _showAlert('Success', 'Registration completed successfully!');
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        _showAlert('Error', response['message']);
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showAlert('Error', 'An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text(
                  'KrishiMitra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your details below',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 30),
                if (!_showVerification) ...[
                  _buildTextField(_usernameController, 'Username'),
                  SizedBox(height: 15),
                  _buildTextField(_emailController, 'Email'),
                  SizedBox(height: 15),
                  _buildTextField(_passwordController, 'Password', obscureText: true),
                  SizedBox(height: 15),
                  _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
                ] else ...[
                  Text(
                    'Enter Verification Code',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(_verificationCodeController, 'Verification Code'),
                ],
                SizedBox(height: 30),
                if (_isLoading || _isVerifying)
                  Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _showVerification ? _verifyEmail : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Center(
                      child: Text(
                        _showVerification ? 'Verify Email' : 'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (!_showVerification) ...[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.apple, Colors.black),
                    ],
                  ),
                ],
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signin'),
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            obscureText ? Icon(Icons.visibility, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
      ),
      padding: EdgeInsets.all(10),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
