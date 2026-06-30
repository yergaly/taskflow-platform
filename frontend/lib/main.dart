import 'package:flutter/material.dart';
import 'package:frontend/features/splash/splash_screen.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Realtime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0C1B),
        primaryColor: const Color(0xFF6366F1),
      ),
      home: const RealtimeLandingScreen(),
    );
  }
}

class RealtimeLandingScreen extends StatefulWidget {
  const RealtimeLandingScreen({super.key});

  @override
  State<RealtimeLandingScreen> createState() => _RealtimeLandingScreenState();
}

class _RealtimeLandingScreenState extends State<RealtimeLandingScreen> {
  // Твои реальные метрики из Google Sheets
  String activeProjects = '0';
  String completedTasks = '0';
  String teamMembers = '0';
  String onTimeRate = '0%';
  List<dynamic> projectsProgress = [];
  bool isLoading = true;

  // URL твоего сервера Mac Studio через Tailscale
  final String _baseUrl = 'https://mac-studio.tailbc593.ts.net';

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/public/stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          activeProjects = data['active_projects'].toString();
          completedTasks = data['completed_tasks'].toString();
          teamMembers = data['team_members'].toString();
          onTimeRate = data['on_time_rate'].toString();
          projectsProgress = data['projects_progress'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Ошибка подключения к Mac Studio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Добавляем аккуратный AppBar наверх, как на исходных макетах
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C1B),
        elevation: 0,
        automaticallyImplyLeading: false, // Убирает дефолтную кнопку назад
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  // 2. Переход на твой скопированный экран логина
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0), // Чуть уменьшил отступ сверху
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Можно убрать старый SizedBox и большую иконку, если они будут дублироваться с AppBar
                    const SizedBox(height: 20),
                    const Icon(Icons.blur_on, size: 80, color: Color(0xFF6366F1)),
                    const SizedBox(height: 24),
                    const Text(
                      '-=BORAS Lab=-\nBusiness Oriented Robotics &\nAutonomous Systems',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                    ),
                    const SizedBox(height: 48),
                    
                    // Блок главных метрик
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(completedTasks, 'Tasks Done'),
                        _buildStatItem(onTimeRate, 'On-Time'),
                        _buildStatItem(activeProjects, 'Projects'),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    const Text(
                      'Projects Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    
                    // Динамический список проектов из Google Sheets
                    if (projectsProgress.isEmpty)
                      const Text('No projects found', style: TextStyle(color: Colors.white30))
                    else
                      ...projectsProgress.map((project) => _buildProjectRow(
                            project['name'] ?? 'Unknown',
                            (project['progress'] ?? 0.0).toDouble(),
                          )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00F5D4))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildProjectRow(String name, double percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1D1830), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${(percent * 100).toInt()}%', style: const TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white10,
            color: const Color(0xFF00F5D4),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}