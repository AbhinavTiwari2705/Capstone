import 'dart:convert';
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://authentication-backend-brown.vercel.app';
  static const storage = FlutterSecureStorage();

  // Authentication endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String verifyEndpoint = '$baseUrl/auth/verify';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh-token';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String predictEndpoint = '$baseUrl/predict';
  static const String predictCattleEndpoint = '$baseUrl/predict_cattle';

  // Token storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isVerifiedKey = 'is_verified';

  // Store tokens
  static Future<void> storeTokens(String accessToken, String refreshToken) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    await storage.write(key: refreshTokenKey, value: refreshToken);
  }

  // Get stored tokens
  static Future<Map<String, String?>> getTokens() async {
    final accessToken = await storage.read(key: accessTokenKey);
    final refreshToken = await storage.read(key: refreshTokenKey);
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // Clear tokens (logout)
  static Future<void> clearTokens() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
    await storage.delete(key: isVerifiedKey);
  }

  // Check if user is verified
  static Future<bool> isUserVerified() async {
    return await storage.read(key: isVerifiedKey) == 'true';
  }

  // Set user as verified
  static Future<void> setUserVerified() async {
    await storage.write(key: isVerifiedKey, value: 'true');
  }

  // Register new user
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      print('Attempting registration with endpoint: $registerEndpoint');
      final requestBody = {
        'username': username,
        'email': email,
        'password': password,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Verification code sent successfully'
          };
        } catch (e) {
          print('JSON Decode Error: $e');
          return {
            'success': false,
            'message': 'Failed to parse server response'
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Registration failed'
          };
        } catch (e) {
          print('Error Response Parse Error: $e');
          final truncatedBody = response.body.length > 100 
              ? response.body.substring(0, 100) + '...' 
              : response.body;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Network Error: $e');
      return {
        'success': false,
        'message': 'Network error: Please check your internet connection'
      };
    }
  }

  // Verify email
  static Future<Map<String, dynamic>> verifyEmail(
      String email, String verificationCode) async {
    try {
      print('Attempting verification with endpoint: $verifyEndpoint');
      final requestBody = {
        'email': email,
        'verificationCode': verificationCode,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(verifyEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'User registered successfully'};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Verification failed'
          };
        } catch (e) {
          final truncatedBody = response.body.length > 100 
              ? response.body.substring(0, 100) + '...' 
              : response.body;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Verification Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final requestBody = {
        'username': username,
        'password': password,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store tokens immediately on successful login
        await storeTokens(data['token'], data['refreshToken']);
        
        // Set verified status if applicable
        if (data['user'] != null && data['user']['isVerified'] == true) {
          await setUserVerified();
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Login failed'
          };
        } catch (e) {
          final truncatedBody = response.body.length > 100 
              ? response.body.substring(0, 100) + '...' 
              : response.body;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Login Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final requestBody = {
        'refreshToken': refreshToken,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Token refresh failed'
          };
        } catch (e) {
          final truncatedBody = response.body.length > 100 
              ? response.body.substring(0, 100) + '...' 
              : response.body;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Refresh Token Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword, String verificationCode) async {
    try {
      final requestBody = {
        'email': email,
        'newPassword': newPassword,
        'verificationCode': verificationCode,
      };
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(resetPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset successful'};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Password reset failed'
          };
        } catch (e) {
          final truncatedBody = response.body.length > 100 
              ? response.body.substring(0, 100) + '...' 
              : response.body;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Reset Password Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Predict from image
  static Future<Map<String, dynamic>> predictFromImage(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(predictEndpoint));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseData');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(responseData),
        };
      } else {
        try {
          final error = jsonDecode(responseData);
          return {
            'success': false,
            'message': error['message'] ?? 'Prediction failed'
          };
        } catch (e) {
          final truncatedBody = responseData.length > 100 
              ? responseData.substring(0, 100) + '...' 
              : responseData;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Predict Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Predict cattle from image
  static Future<Map<String, dynamic>> predictCattle(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(predictCattleEndpoint));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Cattle Prediction Status Code: ${response.statusCode}');
      print('Cattle Prediction Response: $responseData');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(responseData),
        };
      } else {
        try {
          final error = jsonDecode(responseData);
          return {
            'success': false,
            'message': error['message'] ?? 'Cattle prediction failed'
          };
        } catch (e) {
          final truncatedBody = responseData.length > 100 
              ? responseData.substring(0, 100) + '...' 
              : responseData;
          return {
            'success': false,
            'message': 'Server error: $truncatedBody'
          };
        }
      }
    } catch (e) {
      print('Cattle Prediction Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
