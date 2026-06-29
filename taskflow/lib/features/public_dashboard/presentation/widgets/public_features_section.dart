import 'package:flutter/material.dart';

import '../../domain/models/public_dashboard_content.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';

class PublicFeaturesSection extends StatelessWidget {
  const PublicFeaturesSection({super.key, required this.features});

  final List<PublicFeature> features;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.columnsFor(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Built for collaborative teams',
          subtitle:
              'Everything your organization needs to plan, execute, and report with confidence.',
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: columns == 1 ? 1.8 : 1.45,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconFromName(feature.iconName),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    feature.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _iconFromName(String iconName) {
    return switch (iconName) {
      'folder_outlined' => Icons.folder_outlined,
      'groups_outlined' => Icons.groups_outlined,
      'task_alt_outlined' => Icons.task_alt_outlined,
      'description_outlined' => Icons.description_outlined,
      _ => Icons.widgets_outlined,
    };
  }
}
