import 'package:flutter/material.dart';

import '../../domain/models/public_dashboard_content.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';

class PublicStatsSection extends StatelessWidget {
  const PublicStatsSection({super.key, required this.stats});

  final PublicStats stats;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.columnsFor(
      context,
      mobile: 2,
      tablet: 2,
      desktop: 4,
    );

    final cards = [
      StatCard(
        label: 'Total tasks',
        value: stats.totalTasks.toString(),
        icon: Icons.task_alt_outlined,
        helperText: 'Live from workspace data',
      ),
      StatCard(
        label: 'Active projects',
        value: stats.activeProjects.toString(),
        icon: Icons.folder_open_outlined,
        iconColor: AppColors.secondary,
        helperText: 'Derived from task records',
      ),
      StatCard(
        label: 'Team members',
        value: stats.teamMembers.toString(),
        icon: Icons.people_outline,
        iconColor: AppColors.success,
        helperText: 'Unique assignees detected',
      ),
      StatCard(
        label: 'Completed items',
        value: stats.dailyReports.toString(),
        icon: Icons.check_circle_outline,
        iconColor: AppColors.warning,
        helperText: 'Tasks marked done or reported',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Workspace snapshot',
          subtitle: 'A quick overview of current activity in the platform.',
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: columns == 1 ? 2.4 : 1.35,
          ),
          itemBuilder: (context, index) => cards[index],
        ),
      ],
    );
  }
}
