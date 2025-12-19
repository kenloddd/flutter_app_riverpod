// lib/services/ai_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiService {
  // Pake API Key lu yang ini bos
  static const String _apiKey = "AIzaSyBVv4zGNTvHquQYhuHd1Arv3rwvGN8Gs0o";

  Future<String> getDiaryReflection(String content, int moodIndex) async {
    if (content.isEmpty) return "Tulis ceritamu dulu ya bos!";

    // Mapping mood biar AI paham perasaan lu
    final moodLabels = ["Sangat Sedih", "Sedih", "Biasa Saja", "Senang", "Sangat Senang"];
    String userMood = moodIndex != -1 ? moodLabels[moodIndex] : "Biasa Saja";

    try {
      // PERBAIKAN: Pake 'gemini-1.5-flash-latest' biar lebih kompatibel
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest', 
        apiKey: _apiKey
      );
      
      final prompt = """
      Bertindaklah sebagai teman curhat AI yang sangat suportif. 
      Isi diary: "$content"
      Mood user: "$userMood"

      Tugasmu:
      1. Berikan respon hangat dan bijak dalam Bahasa Indonesia.
      2. Jangan kaku, jawab seperti teman akrab.
      3. Maksimal 3 kalimat saja.
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      
      // Jika sukses, balikin teksnya
      if (response.text != null) {
        return response.text!;
      }
      
      return "Wah, ceritamu dalem banget bos. Semangat ya!";

    } catch (e) {
      // Print error asli ke console buat jaga-jaga
      debugPrint("DIAGNOSTIC_ERROR: $e");
      
      // Kalau model flash-latest masih gak ketemu, coba ganti ke 'gemini-pro'
      return "AI lagi narik nafas dulu bos. Coba pencet lagi atau cek kuota API lu!";
    }
  }
}