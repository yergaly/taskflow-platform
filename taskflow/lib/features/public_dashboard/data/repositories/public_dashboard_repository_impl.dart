import '../../domain/models/public_dashboard_content.dart';
import '../../domain/repositories/public_dashboard_repository.dart';
import '../datasources/public_dashboard_remote_datasource.dart';

class PublicDashboardRepositoryImpl implements PublicDashboardRepository {
  PublicDashboardRepositoryImpl({
    required PublicDashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PublicDashboardRemoteDataSource _remoteDataSource;

  @override
  Future<PublicDashboardContent> getDashboardContent() async {
    final tasks = await _remoteDataSource.fetchTasks();

    final recentTaskTitles = tasks
        .map((task) => _readTaskTitle(task))
        .where((title) => title.isNotEmpty)
        .take(5)
        .toList();

    return PublicDashboardContent(
      stats: PublicStats(
        totalTasks: tasks.length,
        activeProjects: _estimateProjects(tasks),
        teamMembers: _estimateTeamMembers(tasks),
        dailyReports: _estimateReports(tasks),
      ),
      features: PublicDashboardContent.defaultFeatures,
      recentTaskTitles: recentTaskTitles,
    );
  }

  String _readTaskTitle(Map<String, dynamic> task) {
    const candidates = ['title', 'name', 'task', 'Task', 'Title', 'Name'];
    for (final key in candidates) {
      final value = task[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  int _estimateProjects(List<Map<String, dynamic>> tasks) {
    final projects = <String>{};
    for (final task in tasks) {
      for (final key in ['project', 'project_name', 'Project']) {
        final value = task[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          projects.add(value.toString().trim().toLowerCase());
        }
      }
    }
    return projects.isEmpty ? 0 : projects.length;
  }

  int _estimateTeamMembers(List<Map<String, dynamic>> tasks) {
    final members = <String>{};
    for (final task in tasks) {
      for (final key in ['assignee', 'participant', 'owner', 'Assignee']) {
        final value = task[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          members.add(value.toString().trim().toLowerCase());
        }
      }
    }
    return members.length;
  }

  int _estimateReports(List<Map<String, dynamic>> tasks) {
    return tasks.where((task) {
      final status = task['status']?.toString().toLowerCase() ?? '';
      return status.contains('report') || status.contains('done');
    }).length;
  }
}
