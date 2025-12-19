import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider global untuk tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Class Notifier yang berisi logika
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // State awal adalah mode terang
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme(); // Langsung muat tema yang tersimpan saat aplikasi dimulai
  }

  // Fungsi untuk memuat tema dari SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Baca 'isDarkMode', jika tidak ada, default-nya false (mode terang)
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Fungsi untuk mengganti dan menyimpan tema
  Future<void> toggleTheme() async {
    // Tentukan tema baru
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newTheme == ThemeMode.dark);
    
    // Update state di memori
    state = newTheme;
  }
}