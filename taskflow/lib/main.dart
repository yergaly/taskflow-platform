import 'package:flutter/material.dart';
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
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0C1B),
        primaryColor: const Color(0xFF6366F1),
      ),
      home: const AuthScreen(),
    );
  }
}

// ==========================================
// 1. ЭКРАН АВТОРИЗАЦИИ И РЕГИСТРАЦИИ
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _message = '';

  final String _baseUrl = 'http://172.20.10.3:8000';

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse(isLoginMode ? '$_baseUrl/auth/login' : '$_baseUrl/auth/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isLoginMode) {
          final token = responseData['access_token'];
          
          // ВМЕСТО ТЕКСТА: Переходим на экран менеджера и передаем туда токен!
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerControlPanelWidget(token: token),
              ),
            );
          }
        } else {
          setState(() {
            _message = 'Регистрация успешна! Теперь войдите.';
            isLoginMode = true;
          });
        }
      } else {
        setState(() {
          _message = 'Ошибка: ${responseData['detail'] ?? 'Что-то пошло не так'}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Не удалось связаться с сервером. Проверь FastAPI!';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.blur_on, size: 80, color: Color(0xFF6366F1)),
                const SizedBox(height: 16),
                Text(
                  isLoginMode ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    filled: true,
                    fillColor: const Color(0xFF1D1830),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val!.contains('@') ? null : 'Введите корректный Email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF1D1830),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val!.length >= 4 ? null : 'Пароль слишком короткий',
                ),
                const SizedBox(height: 24),
                if (_message.isNotEmpty) ...[
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                ],
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitAuth,
                        child: Text(isLoginMode ? 'Sign In' : 'Register', style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLoginMode = !isLoginMode;
                      _message = '';
                    });
                  },
                  child: Text(
                    isLoginMode ? "Don't have an account? Register" : "Already have an account? Sign In",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ЭКРАН ПАНЕЛИ УПРАВЛЕНИЯ (MANAGER PANEL)
// ==========================================
class ManagerControlPanelWidget extends StatefulWidget {
  final String token; // Сюда сохраняется JWT-токен для будущих запросов к API
  const ManagerControlPanelWidget({super.key, required this.token});

  @override
  State<ManagerControlPanelWidget> createState() => _ManagerControlPanelWidgetState();
}

class _ManagerControlPanelWidgetState extends State<ManagerControlPanelWidget> {
  String selectedProject = 'Project Matrix';
  String selectedGroup = 'Group A';

  final TextEditingController participantController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  @override
  void dispose() {
    participantController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manager Control Panel',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'System Status: Optimized',
                        style: TextStyle(fontSize: 14, color: Colors.greenAccent.shade400, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF6366F1),
                    child: const Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Active Projects',
                style: TextStyle(fontSize: 16, color: Color(0xFF948EA5), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildProjectCard('Project Matrix', 'Sarah Chen'),
              _buildProjectCard('Cyber-Shield', 'James Wilson'),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1830),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign Task & Manage Teams',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Select Project',
                            value: selectedProject,
                            items: ['Project Matrix', 'Cyber-Shield'],
                            onChanged: (val) => setState(() => selectedProject = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Select Group',
                            value: selectedGroup,
                            items: ['Group A', 'Group B', 'Security Ops'],
                            onChanged: (val) => setState(() => selectedGroup = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(label: 'Participant', hint: 'Enter name...', controller: participantController),
                    const SizedBox(height: 16),
                    _buildTextField(label: 'Task Description', hint: 'Describe the deliverable...', controller: descriptionController),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Deadline',
                            hint: 'YYYY-MM-DD',
                            controller: deadlineController,
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // Лог в консоль для проверки сбора данных с полей
                            print('Задача: ${descriptionController.text}, Исполнитель: ${participantController.text}');
                          },
                          child: const Text('Assign Task', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1830),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Progress Tracker',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressRow('yergali', '4/5 tasks done', 0.8),
                    const SizedBox(height: 14),
                    _buildProgressRow('ivan_dev', '2/5 tasks done', 0.4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(String title, String lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1D1830), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('Lead: $lead', style: const TextStyle(color: Color(0xFF948EA5), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF948EA5), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF0F0C1B), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
              dropdownColor: const Color(0xFF1D1830),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF948EA5), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0F0C1B),
            filled: true,
            prefixIcon: icon != null ? Icon(icon, color: Colors.white70, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String name, String status, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            Text(status, style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.white10,
          color: const Color(0xFF00F5D4),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
