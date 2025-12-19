# 📓 Diary Notes 

**Diary Notes** adalah aplikasi jurnal digital modern yang dibangun dengan Flutter, dirancang untuk membantu pengguna mencatat momen harian mereka. Aplikasi ini bukan sekadar catatan biasa, ia dilengkapi dengan analisis suasana hati (mood) tentang kesejahteraan emosional pengguna.

## ✨ Fitur Unggulan

* **🤖 AI Reflection (Gemini AI)**: Mendapatkan refleksi dan motivasi personal berdasarkan isi catatan harian Anda menggunakan integrasi Google Gemini AI.
* **📊 Mood Analytics Dashboard**: Visualisasi distribusi suasana hati dalam bentuk grafik donat yang interaktif menggunakan `fl_chart`.
* **📅 Calendar Integration**: Navigasi catatan berdasarkan tanggal dengan mudah menggunakan antarmuka kalender yang intuitif.
* **🔐 Secure Authentication**: Sistem login dan pendaftaran pengguna yang aman menggunakan Firebase Authentication.
* **💾 Hybrid Storage**: Penyimpanan data lokal yang cepat menggunakan SQLite dan sinkronisasi status login melalui Firebase.
* **🌟 Motivation Hub**: Fitur pencarian kata-kata motivasi harian secara real-time dari API publik.
* **🌗 Theme Switching**: Mendukung mode terang dan gelap untuk kenyamanan membaca di berbagai kondisi cahaya.
* **📸 Media Support**: Lampirkan foto pada setiap momen berharga Anda.

## 🛠️ Tech Stack

* **Frontend**: Flutter & Dart
* **State Management**: Riverpod
* **Database**: SQLite (Local) & Firebase (Auth)
* **AI Engine**: Google Gemini AI (Generative AI SDK)
* **Animations**: Flutter Animate
* **Networking**: HTTP Client (ZenQuotes API)

## 🚀 Cara Menjalankan Project

1.  **Clone Repositori**:
    ```bash
    git clone [https://github.com/kenloddd/flutter_app_riverpod.git](https://github.com/kenloddd/flutter_app_riverpod.git)
    ```
2.  **Instal Dependensi**:
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi Firebase**:
    Pastikan Anda sudah menjalankan `flutterfire configure` untuk menghubungkan aplikasi dengan project Firebase Anda.
4.  **Konfigurasi API Key**:
    Masukkan API Key Gemini Anda pada file `lib/services/ai_service.dart`.
5.  **Jalankan Aplikasi**:
    ```bash
    flutter run
    ```

---
Dibuat dengan ❤️ oleh **Kenneth Lodewijk Ibrahim**
