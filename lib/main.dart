// main.dart (simplified MVP for Happit Tracker)

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HappitTracker());
}

class HappitTracker extends StatelessWidget {
  const HappitTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int heartCount = 5;
  int streakCount = 0;
  DateTime? lastDoneDate;
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStreak = prefs.getInt('streakCount') ?? 0;
    final savedHearts = prefs.getInt('heartCount') ?? 5;
    final lastDateStr = prefs.getString('lastDoneDate');
    DateTime? savedDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;

    if (savedDate != null) {
      final daysDiff = DateTime(today.year, today.month, today.day).difference(DateTime(savedDate.year, savedDate.month, savedDate.day)).inDays;
      if (daysDiff > 0) {
        // missed days
        int newHearts = (savedHearts - daysDiff).clamp(0, 5);
        savedDate = savedDate.add(Duration(days: daysDiff));
        setState(() {
          streakCount = 0;
          heartCount = newHearts;
          lastDoneDate = savedDate;
        });
      } else {
        setState(() {
          streakCount = savedStreak;
          heartCount = savedHearts;
          lastDoneDate = savedDate;
        });
      }
    }
  }

  Future<void> markAsDone() async {
    final prefs = await SharedPreferences.getInstance();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (lastDoneDate == null || todayDateOnly.difference(DateTime(lastDoneDate!.year, lastDoneDate!.month, lastDoneDate!.day)).inDays > 0) {
      setState(() {
        streakCount++;
        heartCount = (heartCount + 1).clamp(0, 5);
        lastDoneDate = today;
      });
      await prefs.setInt('streakCount', streakCount);
      await prefs.setInt('heartCount', heartCount);
      await prefs.setString('lastDoneDate', today.toIso8601String());
    }
  }

  String getEmotionImagePath() {
    if (heartCount == 0) return 'assets/emotions/1.png';
    if (heartCount == 1) return 'assets/emotions/2.png';
    if (heartCount == 2) return 'assets/emotions/3.png';
    if (heartCount == 3) return 'assets/emotions/4.png';
    if (heartCount == 4) return 'assets/emotions/5.png';

    // heartCount == 5
    if (streakCount >= 30) return 'assets/emotions/9.png';
    if (streakCount >= 10) return 'assets/emotions/8.png';
    return 'assets/emotions/6.png';
  }

  String getMoodText() {
    switch (heartCount) {
      case 5:
        if (streakCount >= 30) return "You're my hero! 🧡";
        if (streakCount >= 10) return "You're amazing! Keep going!";
        return "You're feeding me well!";
      case 4:
        return "Yummy! Thanks!";
      case 3:
        return "I’m okay... just a bit sleepy...";
      case 2:
        return "Umm... are you forgetting me?";
      case 1:
        return "I'm getting really hungry...";
      default:
        return "You forgot me... 😿";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: SvgPicture.asset(
          'assets/ICON.svg',
          height: 36,
          semanticsLabel: 'Happit Logo',
          placeholderBuilder: (context) => const CircularProgressIndicator(),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Health Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => Icon(
                  index < heartCount ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                )),
              ),
              const SizedBox(height: 24),

              // Emotion Image
              Image.asset(
                getEmotionImagePath(),
                width: 160,
                height: 160,
              ),

              const SizedBox(height: 16),
              Text(
                getMoodText(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                '🔥 Streak: $streakCount days',
                style: const TextStyle(fontSize: 16, color: Color(0xFFEFA68F)),
              ),
              const Spacer(),
              if (lastDoneDate == null ||
                  DateTime(today.year, today.month, today.day)
                      .difference(DateTime(lastDoneDate!.year, lastDoneDate!.month, lastDoneDate!.day))
                      .inDays > 0)
                ElevatedButton(
                  onPressed: markAsDone,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    backgroundColor: Color(0xFFD05E35),
                  ),
                  child: const Text(
                    'Mark as Done',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
