import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/shell/presentation/admin_shell.dart';
import '../features/dashboard/presentation/overview_page.dart';
import '../features/users/presentation/users_page.dart';
import '../features/tracking/presentation/tracking_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/marketing/presentation/marketing_page.dart';
import '../features/support/presentation/reclamations_page.dart';

import '../features/auth/presentation/password_reset_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

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
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AdminShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/overview',
          builder: (context, state) => const OverviewPage(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersPage(),
        ),
        GoRoute(
          path: '/tracking',
          builder: (context, state) => const TrackingPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/marketing',
          builder: (context, state) => const MarketingPage(),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const ReclamationsPage(),
        ),
      ],
    ),
  ],
);
