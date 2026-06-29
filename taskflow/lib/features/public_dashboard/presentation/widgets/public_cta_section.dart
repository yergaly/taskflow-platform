import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

class PublicCtaSection extends StatelessWidget {
  const PublicCtaSection({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AppCard(
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
      borderColor: AppColors.primary.withValues(alpha: 0.15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to join your team workspace?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to access role-based dashboards for participants, team leads, and organization heads.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: AppSpacing.lg),
            AppButton(
              label: 'Get started',
              icon: Icons.login,
              onPressed: onGetStarted,
            ),
          ],
        ],
      ),
    );
  }
}
