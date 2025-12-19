import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QuoteService {
  static const String _baseUrl = "https://zenquotes.io/api/quotes";

  Future<List<Map<String, String>>> fetchQuotes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((q) => {
          "content": q['q'] as String,
          "author": q['a'] as String,
        }).toList();
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    return [];
  }
}