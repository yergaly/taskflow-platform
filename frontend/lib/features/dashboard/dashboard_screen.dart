import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String token;
  final String role;

  const DashboardScreen({super.key, required this.token, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildRoleBasedBody(),
    );
  }

  Widget _buildRoleBasedBody() {
    switch (role) {
      case 'head':
        return _HeadDashboardContent(token: token);
      case 'team_lead':
        return _TeamLeadDashboardContent(token: token);
      case 'member':
      default:
        return _MemberDashboardContent(token: token);
    }
  }
}

// ==========================================
// КОНТЕНТ ДЛЯ HEAD OF PROJECT
// ==========================================
class _HeadDashboardContent extends StatelessWidget {
  final String token;
  const _HeadDashboardContent({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👨‍💼 Head Workspace'), backgroundColor: const Color(0xFF1D1830)),
      body: const Center(child: Text('Управление проектами и командами системного уровня')),
    );
  }
}

// ==========================================
// КОНТЕНТ ДЛЯ TEAM LEAD
// ==========================================
class _TeamLeadDashboardContent extends StatelessWidget {
  final String token;
  const _TeamLeadDashboardContent({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👨‍💻 Team Lead Panel'), backgroundColor: const Color(0xFF1D1830)),
      body: const Center(child: Text('Создание задач и трекинг спринтов вашей группы')),
    );
  }
}

// ==========================================
// КОНТЕНТ ДЛЯ MEMBER
// ==========================================
class _MemberDashboardContent extends StatelessWidget {
  final String token;
  const _MemberDashboardContent({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👤 Member Board'), backgroundColor: const Color(0xFF1D1830)),
      body: const Center(child: Text('Ваш личный список задач из Google Sheets')),
    );
  }
}