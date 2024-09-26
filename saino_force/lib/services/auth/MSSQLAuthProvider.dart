import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'auth_user.dart';
import 'auth_exception.dart';
import 'dart:developer' as devtools show log;
import 'package:shared_preferences/shared_preferences.dart';

class MSSQLAuthProvider implements AuthProvider {
  final String baseUrl = "http://10.0.2.2:3010/api";
  final String toWalletDB = "http://10.0.2.2:3009/api/wallet";
  //final String baseUrl = "http://192.168.1.9:3010/api";
  //final String baseUrl = "http://172.20.10.3:3010/api";

  AuthUser? _currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw GenericAuthException();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      devtools
          .log('Login API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        _currentUser = AuthUser(
          id: responseData['id'],
          username: responseData['username'],
          email: email,
        );

        await _saveUserToPreferences(_currentUser!);
        return _currentUser!;
      } else if (response.statusCode == 404) {
        throw UserNotFoundAuthException();
      } else if (response.statusCode == 401) {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log(email);
      devtools.log('Login Error: $e');
      throw GenericAuthException();
    }
  }

  Future<void> _saveUserToPreferences(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
  }

  @override
  Future<AuthUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final response2 = await http.post(
        Uri.parse('$baseUrl/createWalletandDID'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );
      devtools.log(
          'Register API Response: ${response.statusCode} ${response.body}');
      devtools.log(
          'Register Wallet In SAINO API Response: ${response2.statusCode} ${response2.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _currentUser = AuthUser(
          id: responseData['id'],
          username: responseData['username'],
          email: email,
        );
        await _saveUserToPreferences(_currentUser!);
        return _currentUser!;
      } else if (response.statusCode == 400) {
        throw EmailAlreadyInUseAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log('Register Error: $e');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromPreferences();
  }

  Future<void> _clearUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt('userId');
    devtools.log("Backend Working");
    devtools.log(userId.toString());
    _currentUser = await _getUserFromPreferences();
  }

  Future<AuthUser?> _getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    if (userId != null && username != null && email != null) {
      return AuthUser(
        id: userId,
        username: username,
        email: email,
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> generateQRCode({
    required String userID,
    required String perID,
    required String eduBacID,
    required String cerID,
    required String intelID,
    required String workExpID,
  }) async {
    try {
      final qrData = {
        'userID': userID,
        'PerID': perID,
        'EduBacID': eduBacID,
        'CerID': cerID,
        'IntelID': intelID,
        'WorkExpID': workExpID,
      };

      final response = await http.post(
        Uri.parse('$toWalletDB/generate-qrcode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(qrData),
      );

      devtools.log(
          'Generate QRCode API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        devtools.log('QR Code Hash: ${responseData['qrHash']}');
        devtools.log('QR Code Image Base64: ${responseData['qrCodeImage']}');
        return responseData;
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log('Generate QRCode Error: $e');
      throw GenericAuthException();
    }
  }

  Future<Map<String, dynamic>?> searchQRCode(String qrCode) async {
    try {
      final response = await http.post(
        Uri.parse('$toWalletDB/search-qrcode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'qrHashCode': qrCode,
        }),
      );

      devtools.log(
          'Search QRCode API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log('Search QRCode Error: $e');
      throw GenericAuthException();
    }
  }

  Future<List<Map<String, dynamic>>> fetchQRCodesByUserId(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$toWalletDB/fetch-qrcodes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'userID': userId,
        }),
      );

      devtools.log(
          'Fetch QR Codes by UserID API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['qrCodes']);
      } else {
        return [];
      }
    } catch (e) {
      devtools.log('Fetch QR Codes Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchTalent({
    required String searchType, // "education" or "skills"
    required String searchQuery,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search-talent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'searchType': searchType.toUpperCase(),
          'searchQuery': searchQuery.toUpperCase(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData != null && responseData.isNotEmpty) {
          return List<Map<String, dynamic>>.from(responseData);
        } else {
          return []; // No matching talent found
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      devtools.log('Search Talent Error: $e');
      throw Exception('An error occurred while searching for talent.');
    }
  }

  // New function to fetch detailed information based on UserID
  Future<Map<String, dynamic>?> fetchTalentDetails(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/showDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'userID': userId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        devtools.log(
            'Fetch Talent Details API Response: ${response.statusCode} ${response.body}');
        return responseData;
      } else {
        throw Exception('Failed to retrieve talent details: ${response.body}');
      }
    } catch (e) {
      devtools.log('Fetch Talent Details Error: $e');
      throw Exception('An error occurred while fetching talent details.');
    }
  }

  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verifyPassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      devtools.log(
          'Verify Password API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      devtools.log('Verify Password Error: $e');
      throw GenericAuthException();
    }
  }

  // Change Password
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (newPassword.isEmpty || oldPassword.isEmpty) {
        throw GenericAuthException();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/changePassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      devtools.log(
          'Change Password API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw WrongPasswordAuthException();
        } else if (response.statusCode == 404) {
          throw UserNotFoundAuthException();
        } else {
          throw GenericAuthException();
        }
      }
    } catch (e) {
      devtools.log('Change Password Error: $e');
      throw GenericAuthException();
    }
  }

// Fetch profile data using POST and send userID in the body
  Future<Map<String, dynamic>?> getProfile(int userID) async {
    try {
      // Use POST instead of GET and pass userID in the body
      final response = await http.post(
        Uri.parse('$baseUrl/getProfile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {
        devtools.log('Profile fetched successfully for userID: $userID');
        return jsonDecode(response.body); // Return profile data
      } else {
        devtools.log(
            'Failed to fetch profile for userID $userID: ${response.statusCode}');
        devtools.log(response.body); // Log response for debugging
        return null;
      }
    } catch (e) {
      devtools.log('Error fetching profile for userID $userID: $e');
      return null;
    }
  }

// Save the profile data for the user with the given userID using POST
  Future<bool> saveProfile(int userID, Map<String, dynamic> profileData) async {
    profileData['userID'] = userID; // Include the userID in the profile data

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saveProfile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        devtools.log('Profile saved successfully for userID: $userID');
        return true;
      } else {
        devtools.log(
            'Failed to save profile for userID $userID: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      devtools.log('Error saving profile for userID $userID: $e');
      return false;
    }
  }

  Future<void> storeFeedback(String title, String description, int userId,
      String username, String userEmail) async {
    final url =
        Uri.parse('$baseUrl/saveFeedback'); // Replace with your actual API URL
    devtools.log("calling backend");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userID': userId,
        'username': username,
        'userEmail': userEmail,
        'title': title,
        'description': description,
      }),
    );
    devtools.log("Call Success");

    if (response.statusCode != 200) {
      throw Exception('Failed to store feedback');
    }
  }
}
