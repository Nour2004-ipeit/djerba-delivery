import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/shell/presentation/driver_app_shell.dart';
import '../features/driver/presentation/dashboard_tab.dart';
import '../features/driver/presentation/tasks_tab.dart';
import '../features/driver/presentation/active_tab.dart';
import '../features/driver/presentation/history_tab.dart';
import '../features/driver/presentation/profile_tab.dart';

import '../features/auth/presentation/password_reset_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/two_factor',
      builder: (context, state) {
        final identifier = state.extra as String? ?? '';
        return TwoFactorScreen(identifier: identifier);
      },
    ),
    GoRoute(
      path: '/new_password',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        return NewPasswordScreen(
          identifier: extras['identifier'] ?? '',
          otp: extras['otp'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/password_success',
      builder: (context, state) => const PasswordSuccessScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: email);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DriverAppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/driver_dashboard',
              builder: (context, state) => const DashboardTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/active',
              builder: (context, state) => const ActiveTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryTab(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileTab(),
            ),
          ],
        ),
      ],
    ),
  ],
);
