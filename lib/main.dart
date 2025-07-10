// main.dart (Multi-Habit Version of Happit Tracker with Add/Delete Habit Feature and Styled UI)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  runApp(HappitTracker(showOnboarding: showOnboarding));
}

class HappitTracker extends StatelessWidget {
  final bool showOnboarding;
  const HappitTracker({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),
      home: showOnboarding ? const OnboardingScreen() : const HomePage(),
    );
  }
}



class Habit {
  final String name;
  int heartCount;
  int streakCount;
  DateTime? lastDoneDate;

  Habit({
    required this.name,
    this.heartCount = 5,
    this.streakCount = 0,
    this.lastDoneDate,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    heartCount: json['heartCount'],
    streakCount: json['streakCount'],
    lastDoneDate: json['lastDoneDate'] != null
        ? DateTime.parse(json['lastDoneDate'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'heartCount': heartCount,
    'streakCount': streakCount,
    'lastDoneDate': lastDoneDate?.toIso8601String(),
  };
}
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/emotions/6.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Happit Tracker!",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Track your habits, feed Happy the cat, and build your streak!",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('showOnboarding', false);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: const Text("Let's Start", style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Habit> habits = [];
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsString = prefs.getString('habits');

    if (habitsString != null) {
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(habitsString));
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      bool updated = false;

      setState(() {
        habits = decoded.map((json) {
          final h = Habit.fromJson(json);

          if (h.lastDoneDate != null) {
            final lastDateOnly = DateTime(h.lastDoneDate!.year, h.lastDoneDate!.month, h.lastDoneDate!.day);
            final missedDays = todayDateOnly.difference(lastDateOnly).inDays;

            if (missedDays > 0) {
              h.heartCount = (h.heartCount - missedDays).clamp(0, 5);
              h.streakCount = 0;
              updated = true;
            }
          }

          return h;
        }).toList();
      });

      if (updated) {
        saveHabits(); // Save updated penalties immediately
      }

    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      askForFirstHabit();
    }
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitJsonList = habits.map((h) => h.toJson()).toList();
    await prefs.setString('habits', jsonEncode(habitJsonList));
  }

  void askForFirstHabit() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Welcome to Happit Tracker!', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Name your first habit',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  habits = [Habit(name: name)];
                });
                saveHabits();
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  void markHabitAsDone(int index) {
    final habit = habits[index];
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final lastDateOnly = habit.lastDoneDate == null
        ? null
        : DateTime(habit.lastDoneDate!.year, habit.lastDoneDate!.month, habit.lastDoneDate!.day);

    if (lastDateOnly == null || todayDateOnly.difference(lastDateOnly).inDays > 0) {
      setState(() {
        habit.streakCount++;
        habit.heartCount = (habit.heartCount + 1).clamp(0, 5);
        habit.lastDoneDate = today;
      });
      saveHabits();
    }
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    saveHabits();
  }

  String getEmotionImage(Habit h) {
    if (h.heartCount == 0) return 'assets/emotions/1.png';
    if (h.heartCount == 1) return 'assets/emotions/2.png';
    if (h.heartCount == 2) return 'assets/emotions/3.png';
    if (h.heartCount == 3) return 'assets/emotions/4.png';
    if (h.heartCount == 4) return 'assets/emotions/5.png';
    if (h.streakCount >= 30) return 'assets/emotions/9.png';
    if (h.streakCount >= 10) return 'assets/emotions/8.png';
    return 'assets/emotions/6.png';
  }

  String getMoodText(Habit h) {
    switch (h.heartCount) {
      case 5:
        if (h.streakCount >= 30) return "You're my hero! 🧡";
        if (h.streakCount >= 10) return "You're amazing! Keep going!";
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

  bool shouldShowButton(Habit h) {
    if (h.lastDoneDate == null) return true;
    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastOnly = DateTime(h.lastDoneDate!.year, h.lastDoneDate!.month, h.lastDoneDate!.day);
    return todayOnly.difference(lastOnly).inDays > 0;
  }

  void addNewHabit() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('New Habit', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Habit name',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  habits.add(Habit(name: name));
                });
                saveHabits();
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SvgPicture.asset('assets/ICON.svg', height: 36),
            SvgPicture.asset('assets/Happy.svg', height: 25),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addNewHabit,
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(
        child: Text(
          "No habits yet. Click + to add your first habit!",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: habits.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final h = habits[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              border: Border.all(
                color: h.streakCount >= 10 ? Colors.orangeAccent : Colors.white10,
                width: h.streakCount >= 30 ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            title: const Text("Delete Habit", style: TextStyle(color: Colors.white)),
                            content: const Text("Are you sure you want to delete this habit?", style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteHabit(index);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                      },

                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Icon(
                    i < h.heartCount ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  )),
                ),
                const SizedBox(height: 12),
                Image.asset(getEmotionImage(h), height: 100),
                const SizedBox(height: 12),
                Text(
                  getMoodText(h),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '🔥 Streak: ${h.streakCount} days',
                  style: const TextStyle(color: Color(0xFFEFA68F)),
                ),
                const SizedBox(height: 12),
                if (shouldShowButton(h))
                  ElevatedButton(
                    onPressed: () => markHabitAsDone(index),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color(0xFFFEA571),
                      elevation: 6,
                      shadowColor: Colors.black45,
                      side: const BorderSide(color: Color(0xFFFFD6B0), width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                else
                  const Text("✔ Already marked today", style: TextStyle(color: Colors.greenAccent)),
              ],
            ),
          );
        },
      ),
    );
  }
}

