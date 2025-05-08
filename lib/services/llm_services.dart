import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<Map<String, dynamic>> parseCommand(String command) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''
              Analyze this task command and return JSON with:
              - action: "create", "update", or "delete"
              - title: task title
              - description: task description (optional)
              - date_time: in format "yyyy-MM-dd HH:mm" (optional)
              
              Respond ONLY with valid JSON. Example:
              {
                "action": "create",
                "title": "Team Meeting",
                "description": "Weekly sync",
                "date_time": "2025-12-05 20:50"
              }
              
              Command: "$command"
              '''
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to parse command: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error processing Gemini request: $e');
    }
  }
}