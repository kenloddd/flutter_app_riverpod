// lib/screens/image_viewer_screen.dart (KODE LENGKAP)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart'; // Pastikan package ini sudah ditambahkan

class ImageViewerScreen extends StatelessWidget {
  final String imagePath; // Path gambar yang akan ditampilkan

  const ImageViewerScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam untuk gambar
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Hapus bayangan
        // Ganti tombol back default dengan tombol close
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)), // Tampilkan gambar dari file
          minScale: PhotoViewComputedScale.contained * 0.9, // Sedikit lebih kecil dari layar
          maxScale: PhotoViewComputedScale.covered * 3,   // Bisa zoom lebih besar
          enableRotation: false, // Nonaktifkan rotasi agar lebih simpel
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          // Indikator loading saat gambar dimuat
          loadingBuilder: (context, event) {
            return Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  // Hitung progres download jika tersedia
                  value: event == null || event.expectedTotalBytes == null
                      ? null // Tampilkan loading tak terbatas jika total byte tidak diketahui
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          // Tampilan jika gambar gagal dimuat
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined, color: Colors.grey, size: 60),
                  SizedBox(height: 10),
                  Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}