import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';

class PublicDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PublicDashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AppBar(
      toolbarHeight: 72,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Public workspace overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text('Sign in'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Padding(
          padding: EdgeInsets.only(
            right: isMobile ? AppSpacing.sm : AppSpacing.md,
          ),
          child: AppButton(
            label: isMobile ? 'Sign in' : 'Get started',
            icon: Icons.arrow_forward,
            onPressed: () => context.push(AppRoutes.register),
          ),
        ),
      ],
    );
  }
}
