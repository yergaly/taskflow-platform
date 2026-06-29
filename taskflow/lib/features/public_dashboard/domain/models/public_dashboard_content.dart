import 'package:equatable/equatable.dart';

class PublicFeature extends Equatable {
  const PublicFeature({
    required this.title,
    required this.description,
    required this.iconName,
  });

  final String title;
  final String description;
  final String iconName;

  @override
  List<Object?> get props => [title, description, iconName];
}

class PublicStats extends Equatable {
  const PublicStats({
    required this.totalTasks,
    required this.activeProjects,
    required this.teamMembers,
    required this.dailyReports,
  });

  final int totalTasks;
  final int activeProjects;
  final int teamMembers;
  final int dailyReports;

  bool get isEmpty =>
      totalTasks == 0 &&
      activeProjects == 0 &&
      teamMembers == 0 &&
      dailyReports == 0;

  @override
  List<Object?> get props =>
      [totalTasks, activeProjects, teamMembers, dailyReports];
}

class PublicDashboardContent extends Equatable {
  const PublicDashboardContent({
    required this.stats,
    required this.features,
    required this.recentTaskTitles,
  });

  final PublicStats stats;
  final List<PublicFeature> features;
  final List<String> recentTaskTitles;

  static const defaultFeatures = [
    PublicFeature(
      title: 'Project Management',
      description:
          'Organize initiatives with clear ownership, timelines, and visibility across your organization.',
      iconName: 'folder_outlined',
    ),
    PublicFeature(
      title: 'Team Groups',
      description:
          'Structure participants into focused groups with dedicated team leads and responsibilities.',
      iconName: 'groups_outlined',
    ),
    PublicFeature(
      title: 'Task Tracking',
      description:
          'Assign, monitor, and complete tasks with role-aware workflows for every contributor.',
      iconName: 'task_alt_outlined',
    ),
    PublicFeature(
      title: 'Daily Reports',
      description:
          'Capture progress through daily reports with optional anonymity and image attachments.',
      iconName: 'description_outlined',
    ),
  ];

  @override
  List<Object?> get props => [stats, features, recentTaskTitles];
}
