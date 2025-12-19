import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/database_helper.dart';
import '../models/diary_entry.dart';
import 'auth_provider.dart'; 

class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  DiaryNotifier() : super([]);

  // Ambil UID user yang sedang aktif secara real-time
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadEntries() async {
    if (_currentUserId == null) {
      state = []; // Kalo nggak ada user, kosongin list biar aman
      return;
    }
    final entries = await DatabaseHelper.instance.getEntriesByUser(_currentUserId!);
    state = entries;
  }

  Future<void> addEntry(String title, String content, int moodIndex, List<String> imagePaths, DateTime date) async {
    if (_currentUserId == null) return;
    
    final now = DateTime.now();
    final entryDate = DateTime(date.year, date.month, date.day, now.hour, now.minute, now.second);
    
    final newEntry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId!, // Pastikan UID masuk ke DB
      title: title.isEmpty ? "Untitled Moment" : title,
      content: content, 
      date: entryDate, 
      moodIndex: moodIndex, 
      imagePaths: imagePaths,
    );
    
    await DatabaseHelper.instance.insert(newEntry);
    state = [newEntry, ...state];
  }

  Future<void> updateEntry(String id, String title, String content, int moodIndex, List<String> imagePaths) async {
    if (_currentUserId == null) return;

    final originalEntry = state.firstWhere(
      (e) => e.id == id, 
      orElse: () => throw Exception("Entry not found"),
    );

    final updatedEntry = DiaryEntry(
      id: id, 
      userId: _currentUserId!,
      title: title.isEmpty ? "Untitled Moment" : title, 
      content: content,
      moodIndex: moodIndex, 
      imagePaths: imagePaths, 
      date: originalEntry.date, 
    );

    await DatabaseHelper.instance.update(updatedEntry);
    state = state.map((entry) => entry.id == id ? updatedEntry : entry).toList();
  }
      
  Future<void> deleteEntry(String id) async {
    if (_currentUserId == null) return;
    await DatabaseHelper.instance.delete(id, _currentUserId!);
    state = state.where((entry) => entry.id != id).toList();
  }
}

// == PROVIDER REAKTIF ==
final diaryProvider = StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>((ref) {
  // Pantau status login. Kalo auth berubah, provider ini bakal RE-RUN dari nol
  ref.watch(authStateProvider); 
  return DiaryNotifier()..loadEntries(); 
});