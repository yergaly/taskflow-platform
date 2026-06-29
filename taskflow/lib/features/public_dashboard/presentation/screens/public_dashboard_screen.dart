import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../viewmodels/public_dashboard_viewmodel.dart';
import '../widgets/public_cta_section.dart';
import '../widgets/public_dashboard_app_bar.dart';
import '../widgets/public_features_section.dart';
import '../widgets/public_hero_section.dart';
import '../widgets/public_recent_tasks_section.dart';
import '../widgets/public_stats_section.dart';

class PublicDashboardScreen extends StatefulWidget {
  const PublicDashboardScreen({super.key});

  @override
  State<PublicDashboardScreen> createState() => _PublicDashboardScreenState();
}

class _PublicDashboardScreenState extends State<PublicDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicDashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PublicDashboardViewModel>();
    final content = viewModel.displayContent;
    final padding = Responsive.pagePaddingOf(context);

    return AppScaffold(
      appBar: const PublicDashboardAppBar(),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: viewModel.loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PublicHeroSection(
                onGetStarted: () => context.push(AppRoutes.register),
                onSignIn: () => context.push(AppRoutes.login),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (viewModel.state == ViewState.loading)
                const _StatsLoadingBanner()
              else if (viewModel.state == ViewState.error)
                _StatsErrorBanner(
                  message: viewModel.errorMessage ?? 'Unable to load live stats.',
                  onRetry: viewModel.loadDashboard,
                )
              else ...[
                PublicStatsSection(stats: content.stats),
                if (content.recentTaskTitles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  PublicRecentTasksSection(
                    taskTitles: content.recentTaskTitles,
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.xl),
              PublicFeaturesSection(features: content.features),
              const SizedBox(height: AppSpacing.xl),
              PublicCtaSection(
                onGetStarted: () => context.push(AppRoutes.register),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsLoadingBanner extends StatelessWidget {
  const _StatsLoadingBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Loading live workspace stats...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsErrorBanner extends StatelessWidget {
  const _StatsErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.warning.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Live stats unavailable',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.outline,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
