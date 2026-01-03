import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';
import '../secrets.dart';

class GeminiService {
  // ⚠️ SECURITY NOTE: In production, do not hardcode keys. Use --dart-define or a backend proxy.
  static const String _apiKey = Secrets.geminiApiKey;
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // Flash is faster/cheaper for text extraction
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
          "notes": "A simplified, easy-to-understand summary of the report in plain language without medical jargon. Explain what the results mean in simple terms that a non-medical person can understand. Highlight any concerns or good news. Write 2-3 sentences maximum.",
          "testResults": [
            {
              "testName": "String",
              "value": "String",
              "unit": "String",
              "status": "String (must be exactly one of: 'normal', 'high', 'low', 'critical')",
              "date": "ISO-8601 Date String",
              "simpleExplanation": "A brief, jargon-free explanation of what this test result means in simple terms. Explain what the test measures and what the result indicates in everyday language. 1-2 sentences maximum."
            }
          ]
        }
        
        IMPORTANT INSTRUCTIONS:
        - Write the "notes" field in plain, everyday language that anyone can understand
        - Avoid medical terminology - use simple explanations like "your blood sugar is good" instead of "glucose levels are within normal parameters"
        - For each test result, include a "simpleExplanation" that explains what the result means in non-medical terms
        - If a value is missing, use "N/A". Ensure numeric values are cleaned of text.
        - Make explanations friendly and reassuring when results are normal, and clear but not alarming when there are concerns
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
