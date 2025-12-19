// lib/widgets/diary_entry_card.dart (PERBAIKAN FINAL EDIT + WARNA GESER UNGU)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../screens/entry_screen.dart';
import '../screens/image_viewer_screen.dart';

class DiaryEntryCard extends ConsumerWidget {
  final DiaryEntry entry;
  const DiaryEntryCard({super.key, required this.entry});

  final List<IconData> _moodIcons = const [
    Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dismissible untuk fitur geser-hapus
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Delete Entry'),
              content: const Text('Are you sure you want to delete this moment?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                TextButton(
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(diaryProvider.notifier).deleteEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Moment deleted'), duration: Duration(seconds: 2)),
        );
      },
      // == PERBAIKAN WARNA LATAR BELAKANG GESER ==
      background: Container(
        decoration: BoxDecoration(
           // ignore: deprecated_member_use
           color: Colors.deepPurple.shade100.withOpacity(0.5), // Warna ungu muda
           borderRadius: BorderRadius.circular(20), // Samakan radius
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Samakan margin
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Icon(Icons.delete_outline, color: Colors.deepPurple.shade700), // Ikon ungu
      ),
      // == STRUKTUR CHILD YANG BENAR: Card dulu, baru InkWell di dalamnya ==
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Margin kartu
        elevation: 4,
        shadowColor: Colors.black.withAlpha((255 * 0.05).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Clip Behavior agar InkWell tidak keluar Card
        clipBehavior: Clip.antiAlias, // Penting agar InkWell mengikuti shape Card
        child: InkWell( // InkWell SEBAGAI CHILD dari Card
          onTap: () { // Fungsi onTap HARUS ada di sini untuk EDIT
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EntryScreen(
                  selectedDate: DateTime(entry.date.year, entry.date.month, entry.date.day),
                  entryToEdit: entry, // Kirim data entri untuk diedit
                ),
                fullscreenDialog: true,
              ),
            );
          },
          child: Padding( // Padding isi kartu
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Tanggal (Pastikan ini ada)
                Column(
                  children: [
                    Text(DateFormat('d').format(entry.date),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(DateFormat('MMM').format(entry.date),
                        style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                // Kolom Konten Utama (Pastikan ini ada)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Mood & Waktu
                      Row(
                        children: [
                          Icon(_moodIcons[entry.moodIndex.clamp(0, _moodIcons.length - 1)], color: Colors.grey[700], size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('hh:mm a').format(entry.date),
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Judul
                      Text(entry.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      // Konten
                      if (entry.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text( entry.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], height: 1.4),
                        ),
                      ],
                      // Gambar
                      if (entry.imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: entry.imagePaths.length,
                            itemBuilder: (context, index) {
                              final imagePath = entry.imagePaths[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewerScreen(imagePath: imagePath),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: imagePath + entry.id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(imagePath), width: 50, height: 50, fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                          Container(width: 50, height: 50, color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                // Tombol Hapus TIDAK ADA (pakai swipe)
              ],
            ),
          ),
        ),
      ),
    ) // Akhir Dismissible
    // Animasi muncul saat pertama kali
    .animate().fade(duration: 500.ms).slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut);
  }
}