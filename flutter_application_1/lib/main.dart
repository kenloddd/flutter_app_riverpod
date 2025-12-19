// lib/main.dart (VERSI LENGKAP: TEMA + FIREBASE AUTH)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // TAMBAHAN: Firebase
import 'firebase_options.dart'; // TAMBAHAN: File config yang baru dibuat
import 'helpers/database_helper.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart'; // TAMBAHAN: Provider Auth
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // TAMBAHAN: Halaman Login

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // == INISIALISASI FIREBASE (TAMBAHAN) ==
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Beri sedikit jeda agar splash screen terlihat
  await Future.delayed(const Duration(milliseconds: 1500)); 
  await DatabaseHelper.instance.database;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    // == CEK STATUS LOGIN USER (TAMBAHAN) ==
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diary Notes',
      
      // Tema untuk Mode Terang (Tetap sesuai kodingan lu)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC), 
        cardTheme: CardThemeData( 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
      ),
      
      // Tema untuk Mode Gelap (Tetap sesuai kodingan lu)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1C1B20),
        cardTheme: CardThemeData( 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
         appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white70, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white70),
        ),
      ),
      
      themeMode: themeMode,
      
      // == LOGIKA PINDAH HALAMAN OTOMATIS (TAMBAHAN) ==
      home: authState.when(
        data: (user) {
          // Jika user sudah login (tidak null), langsung ke HomeScreen
          // Jika belum login, tampilkan LoginScreen
          if (user != null) return const HomeScreen();
          return const LoginScreen();
        },
        // Tampilan saat aplikasi lagi ngecek status login ke Firebase
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        // Jika ada error koneksi ke Firebase
        error: (e, st) => Scaffold(
          body: Center(child: Text("Error Firebase: $e")),
        ),
      ),
    );
  }
}