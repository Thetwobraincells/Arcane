import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../secrets.dart';
// ...

class GeminiService {
  // ⚠️ SECURITY NOTE: In production, do not hardcode keys. Use --dart-define or a backend proxy.
  static const String _apiKey = 'AIzaSyC55Y0HNPagmyrDJY-e0wi7vywfdaZRvjY';
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Flash is faster/cheaper for text extraction
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON output
      ),
    );
  }

  Future<LabReport> analyzeImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    
    // 1. The Prompt: Teach Gemini your Data Model
    final prompt = Content.multi([
      TextPart('''
        Analyze this medical lab report image. Extract the data and return ONLY a JSON object.
        
        The JSON must match this exact schema:
        {
          "patientName": "String",
          "patientId": "String (or 'Unknown')",
          "reportDate": "ISO-8601 Date String",
          "notes": "Short summary of the report's overall finding",
          "testResults": [
            {
              "testName": "String",
              "value": "String",
              "unit": "String",
              "status": "String (must be exactly one of: 'normal', 'high', 'low', 'critical')",
              "date": "ISO-8601 Date String"
            }
          ]
        }
        
        If a value is missing, use "N/A". Ensure numeric values are cleaned of text.
      '''),
      DataPart('image/jpeg', imageBytes), // Supports png/jpeg/webp
    ]);

    // 2. Send to Gemini
    final response = await _model.generateContent([prompt]);
    
    // 3. Parse Response
    if (response.text == null) throw Exception('AI returned empty response');
    
    // Clean up markdown code blocks if present (e.g. ```json ... ```)
    String cleanJson = response.text!.replaceAll(RegExp(r'```json|```'), '').trim();
    
    try {
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      // 4. Convert to your existing App Models
      // We generate a random ID since the API won't give one
      data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      return LabReport.fromJson(data);
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
