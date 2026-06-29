import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/placeholder_auth_screen.dart';
import '../../features/public_dashboard/presentation/screens/public_dashboard_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.publicDashboard,
    routes: [
      GoRoute(
        path: AppRoutes.publicDashboard,
        builder: (context, state) => const PublicDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const PlaceholderAuthScreen(
          title: 'Sign in',
          description:
              'Access your role-based dashboard as a participant, team lead, or head.',
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const PlaceholderAuthScreen(
          title: 'Create account',
          description:
              'Register to join your organization workspace and start collaborating.',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
