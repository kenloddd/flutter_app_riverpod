import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaryProvider);

    // Logic: Hitung jumlah tiap mood
    Map<int, int> moodCounts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0};
    for (var entry in entries) {
      moodCounts[entry.moodIndex] = (moodCounts[entry.moodIndex] ?? 0) + 1;
    }

    final total = entries.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Mood Insights"), centerTitle: true),
      body: total == 0
          ? const Center(child: Text("Not enough data to analyze your mood."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Ringkasan Total
                  _buildStatCard("Total Stories", total.toString(), Icons.auto_stories),
                  const SizedBox(height: 24),

                  // 2. Donut Chart
                  const Text("Mood Distribution", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 60,
                        sections: _buildPieSections(moodCounts),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack), // FIXED: Nama Curve yang bener
                  ),

                  const SizedBox(height: 30),

                  // 3. Legend/Keterangan
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurple.shade300]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3), 
            blurRadius: 12, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(icon, color: Colors.white24, size: 50),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  List<PieChartSectionData> _buildPieSections(Map<int, int> counts) {
    final colors = [Colors.orange, Colors.blue, Colors.grey, Colors.red, Colors.pink];
    return List.generate(5, (i) {
      final value = counts[i]!.toDouble();
      return PieChartSectionData(
        color: colors[i],
        value: value,
        title: value > 0 ? '${value.toInt()}' : '',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
    });
  }

  Widget _buildLegend() {
    final labels = ["Happy", "Neutral", "Sad", "Angry", "Love"];
    final colors = [Colors.orange, Colors.blue, Colors.grey, Colors.red, Colors.pink];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: List.generate(5, (i) {
        // FIXED: Efek staggered (muncul satu-satu) dipindah ke item-nya langsung
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(labels[i]),
          ],
        ).animate(delay: (i * 100).ms).fadeIn().slideY(begin: 0.2);
      }),
    );
  }
}