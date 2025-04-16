import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpHelper {
  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Check if the response status code is 2xx (success)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse and return the response body if successful
        return json.decode(response.body);
      } else {
        // Return an error message in case of an unsuccessful response
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle any network or other errors
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
