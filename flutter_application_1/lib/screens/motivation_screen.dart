import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/quote_service.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _allQuotes = [];
  List<Map<String, String>> _filteredQuotes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  void _loadQuotes() async {
    setState(() => _isLoading = true);
    final data = await QuoteService().fetchQuotes();
    setState(() {
      _allQuotes = data;
      _filteredQuotes = data;
      _isLoading = false;
    });
  }

  void _filterQuotes(String query) {
    setState(() {
      _filteredQuotes = _allQuotes
          .where((q) => q['content']!.toLowerCase().contains(query.toLowerCase()) || 
                        q['author']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivation Hub"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterQuotes,
              decoration: InputDecoration(
                hintText: "Search your mood (e.g. life, fear, hope)",
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.deepPurple.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredQuotes.isEmpty
                ? const Center(child: Text("No quotes found for that mood."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredQuotes.length,
                    itemBuilder: (context, index) {
                      final q = _filteredQuotes[index];
                      return GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: "${q['content']} — ${q['author']}"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Quote copied to clipboard!"), duration: Duration(seconds: 1)),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.deepPurple.withValues(alpha: 0.03),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.format_quote_rounded, color: Colors.deepPurple, size: 30),
                                Text(q['content']!, style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 10),
                                Align(alignment: Alignment.centerRight, child: Text("— ${q['author']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}