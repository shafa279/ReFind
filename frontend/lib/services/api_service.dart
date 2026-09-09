```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Login using College / Student ID and password
  static Future<Map<String, dynamic>> login(
    String userId,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        body: {
          'user_id': userId,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Login failed',
        'user_id': data['user_id'],
        'role': data['role'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  // Test connection with Flask backend
  static Future<String> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
      );

      if (response.statusCode == 200) {
        return response.body;
      }

      return 'Server error: ${response.statusCode}';
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  // Submit a lost or found item report
  static Future<Map<String, dynamic>> submitReport({
    required String userId,
    required String itemType,
    required String itemName,
    required String category,
    required String location,
    required String date,
    required String time,
    required String publicDetails,
    required String privateDetails,
    String? imageName,
    List<int>? imageBytes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/report'),
      );

      request.fields['item_type'] = itemType;
      request.fields['item_name'] = itemName;
      request.fields['category'] = category;
      request.fields['location'] = location;
      request.fields['date'] = date;
      request.fields['time'] = time;
      request.fields['public_details'] = publicDetails;
      request.fields['private_details'] = privateDetails;
      request.fields['reporter_id'] = userId;

      if (imageBytes != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Report submission failed',
        'item_id': data['item_id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  // Get all reports
  static Future<List<dynamic>> getMyReports(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/items'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final items = data['items'] ?? [];

        // Keep only reports created by the logged-in user
        return items.where((item) {
          return item['reporter_id'] == userId;
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Get potential matches for an item
  static Future<List<dynamic>> getMatches(int itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/matches/$itemId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['matches'] ?? [];
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
```
