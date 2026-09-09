import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // =========================
  // LOGIN
  // =========================

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

  // =========================
  // TEST CONNECTION
  // =========================

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

  // =========================
  // SUBMIT REPORT
  // =========================

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

  // =========================
  // GET MY REPORTS
  // =========================

  static Future<List<dynamic>> getMyReports(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/items'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final items = data['items'] ?? [];

        return items.where((item) {
          return item['reporter_id'] == userId;
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET MATCHES
  // =========================

  static Future<List<dynamic>> getMatches(
    int itemId,
  ) async {
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

  // =========================
  // GET SINGLE ITEM
  // =========================

  static Future<Map<String, dynamic>?> getItem(
    int itemId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/items'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final items = data['items'] ?? [];

        for (final item in items) {
          if (item['id'] == itemId) {
            return Map<String, dynamic>.from(item);
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // CREATE CLAIM
  // =========================

  static Future<Map<String, dynamic>> createClaim({
    required int itemId,
    required String claimantId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/claims'),
        body: {
          'item_id': itemId.toString(),
          'claimant_id': claimantId,
        },
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Claim failed',
        'claim_id': data['claim_id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  // =========================
  // GET NOTIFICATIONS
  // =========================

  static Future<List<dynamic>> getNotifications(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['notifications'] ?? [];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // MARK NOTIFICATION AS READ
  // =========================

  static Future<bool> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/notifications/$notificationId/read',
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // SUBMIT VERIFICATION
  // =========================

  static Future<Map<String, dynamic>> submitVerification({
    required int claimId,
    required String verificationDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verification'),
        body: {
          'claim_id': claimId.toString(),
          'verification_details': verificationDetails,
        },
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message':
            data['message'] ?? 'Verification submission failed',
        'verification_id': data['verification_id'],
        'claim_id': data['claim_id'],
        'item_id': data['item_id'],
        'reporter_id': data['reporter_id'],
        'claimant_id': data['claimant_id'],
        'status': data['status'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  // =========================
  // GET VERIFICATION
  // =========================

  static Future<Map<String, dynamic>?> getVerification(
    int verificationId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/verification/$verificationId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['verification'] != null) {
          return Map<String, dynamic>.from(
            data['verification'],
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // REVIEW VERIFICATION
  // =========================

  static Future<Map<String, dynamic>> reviewVerification({
    required int verificationId,
    required String reviewerId,
    required String decision,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/verification/$verificationId/review',
        ),
        body: {
          'reviewer_id': reviewerId,
          'decision': decision,
        },
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message':
            data['message'] ?? 'Verification review failed',
        'verification_id': data['verification_id'],
        'claim_id': data['claim_id'],
        'item_id': data['item_id'],
        'decision': data['decision'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }
}