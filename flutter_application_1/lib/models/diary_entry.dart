class DiaryEntry {
  final String id;
  final String userId; // TAMBAHKAN INI
  final String title;
  final String content;
  final DateTime date;
  final int moodIndex;
  final List<String> imagePaths;

  DiaryEntry({
    required this.id,
    required this.userId, // TAMBAHKAN INI
    required this.title,
    required this.content,
    required this.date,
    required this.moodIndex,
    required this.imagePaths,
  });

  // Update ToMap dan FromMap agar support userId
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // TAMBAHKAN INI
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'moodIndex': moodIndex,
      'imagePaths': imagePaths.join(','),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      userId: map['userId'] ?? '', // TAMBAHKAN INI
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      moodIndex: map['moodIndex'],
      imagePaths: map['imagePaths'] != '' ? (map['imagePaths'] as String).split(',') : [],
    );
  }
}