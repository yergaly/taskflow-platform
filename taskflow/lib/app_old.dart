import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_dependencies.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/public_dashboard/presentation/viewmodels/public_dashboard_viewmodel.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PublicDashboardViewModel>(
          create: (_) => PublicDashboardViewModel(
            repository: dependencies.publicDashboardRepository,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
