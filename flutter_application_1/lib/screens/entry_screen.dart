// lib/screens/entry_screen.dart 

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../services/ai_service.dart'; 
import 'image_viewer_screen.dart';

class EntryScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final DiaryEntry? entryToEdit;

  const EntryScreen({
    super.key,
    required this.selectedDate,
    this.entryToEdit,
  });

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedMoodIndex = -1;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isAiLoading = false; 

  final List<IconData> _moodIcons = [
    Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _titleController.text = widget.entryToEdit!.title;
      _contentController.text = widget.entryToEdit!.content;
      _selectedMoodIndex = widget.entryToEdit!.moodIndex;
      _selectedImages = widget.entryToEdit!.imagePaths.map((path) => File(path)).toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // == LOGIKA PANGGIL GEMINI AI (SUDAH FIXED) ==
  void _getAiReflection() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write your thoughts first so Gemini can reflect on them!')),
      );
      return;
    }

    setState(() => _isAiLoading = true);
    
    // Kirim konten DAN mood index biar AI-nya nyambung
    final reflection = await AiService().getDiaryReflection(
      _contentController.text, 
      _selectedMoodIndex
    );
    
    setState(() => _isAiLoading = false);

    if (mounted) {
      _showAiBottomSheet(reflection);
    }
  }

  void _showAiBottomSheet(String reflection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Text("Gemini Insight", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade400)),
              ],
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 20),
            Text(reflection, style: const TextStyle(fontSize: 16, height: 1.6, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Thank You, Gemini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _saveEntry() async {
    if (_selectedMoodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood before saving.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    final imagePaths = _selectedImages.map((file) => file.path).toList();

    if (widget.entryToEdit == null) {
      await ref.read(diaryProvider.notifier).addEntry(
            _titleController.text, _contentController.text,
            _selectedMoodIndex, imagePaths, widget.selectedDate,
          );
    } else {
      await ref.read(diaryProvider.notifier).updateEntry(
            widget.entryToEdit!.id, _titleController.text, _contentController.text,
            _selectedMoodIndex, imagePaths,
          );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isAiLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.amber),
              onPressed: _getAiReflection,
              tooltip: 'AI Reflection',
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),

          TextButton(
            onPressed: _isLoading ? null : _saveEntry,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple))
                : const Text('SAVE', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text('How are you?', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = index),
                  child: Icon(
                    _moodIcons[index],
                    size: 40,
                    color: _selectedMoodIndex == index ? Colors.deepPurple : Colors.grey[300],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField( 
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title your moment...', border: InputBorder.none),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField( 
              controller: _contentController,
              decoration: const InputDecoration(hintText: 'Write your thoughts here...', border: InputBorder.none),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            SizedBox( 
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return _buildAddPhotoButton();
                  }
                  return _buildImageThumbnail(_selectedImages[index], index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100, height: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
      ),
    );
  }

  Widget _buildImageThumbnail(File image, int index) {
    final imagePath = image.path;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageViewerScreen(imagePath: imagePath), fullscreenDialog: true));
      },
      child: Container(
        width: 100, height: 100,
        margin: const EdgeInsets.only(right: 10),
        child: Stack(
          children: [
            Hero(
              tag: imagePath + (widget.entryToEdit?.id ?? 'new'),
              child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(image, fit: BoxFit.cover, width: 100, height: 100)),
            ),
            Positioned(
              top: 0, right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}