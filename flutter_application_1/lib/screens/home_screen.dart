// lib/screens/home_screen.dart (VERSI FINAL: CALENDAR + AUTH + MOTIVATION + ANALYTICS)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/diary_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart'; 
import '../widgets/diary_entry_card.dart';
import 'entry_screen.dart';
import 'motivation_screen.dart';
import 'analytics_screen.dart'; // IMPORT BARU: Dashboard Grafik

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(diaryProvider);
    final filteredEntries = allEntries.where((entry) {
      return isSameDay(entry.date, _selectedDay);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Notes'),
        centerTitle: true,
        actions: [
          // == 1. TOMBOL BARU: MOOD INSIGHTS (ANALYTICS) ==
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.blueAccent),
            tooltip: 'Mood Insights',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),

          // == 2. TOMBOL: MOTIVATION HUB ==
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined, color: Colors.amber),
            tooltip: 'Motivation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MotivationScreen()),
              );
            },
          ),
          
          // == 3. TOMBOL: LOGOUT ==
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin mau keluar dari akun kamu?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authControllerProvider).signOut();
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // == 4. TOMBOL: DARK MODE TOGGLE ==
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                ref.watch(themeProvider) == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                key: ValueKey(ref.watch(themeProvider)), 
              ),
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.week,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.transparent),
                todayTextStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredEntries.isEmpty
                ? const Center(
                    child: Text("No moments recorded for this day.",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return DiaryEntryCard(entry: entry);
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EntryScreen(selectedDate: _selectedDay!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutQuart; 
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      )
      .animate()
      .scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut),
    );
  }
}