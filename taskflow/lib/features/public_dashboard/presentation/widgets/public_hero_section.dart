import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/section_header.dart';

class PublicHeroSection extends StatelessWidget {
  const PublicHeroSection({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            badge: 'Guest Dashboard',
            title: 'Manage projects, teams, and daily progress in one place',
            description:
                'TaskFlow helps educational organizations, research labs, and student project groups coordinate work with clarity and accountability.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'Create account',
                icon: Icons.person_add_outlined,
                onPressed: onGetStarted,
              ),
              AppButton(
                label: 'Sign in',
                variant: AppButtonVariant.outline,
                onPressed: onSignIn,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
