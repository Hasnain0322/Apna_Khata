import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AiService {
  // IMPORTANT: Remember to update this with your computer's current IP address.
  final String _baseUrl = 'http://192.168.0.103:5000'; // <-- UPDATE AS NEEDED

  /// Sends a short, single sentence for ML-based processing.
  Future<Map<String, dynamic>?> processExpenseText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'text': text}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to process text. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error connecting to AI service for text processing: $e');
      return null;
    }
  }

  /// Uploads a receipt image for backend processing with Google Cloud Vision.
  Future<Map<String, dynamic>?> analyzeReceiptImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/process-image-receipt')
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'receipt',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        )
      );
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to analyze receipt image: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading/analyzing receipt image: $e");
      return null;
    }
  }
}