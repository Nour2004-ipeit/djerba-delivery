import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/shell/presentation/restaurant_shell.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/orders/presentation/live_orders_page.dart';
import '../features/menu/presentation/menu_page.dart';
import '../features/restaurant/presentation/settings_page.dart';

import '../features/auth/presentation/password_reset_screens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Router Error: ${state.error}'))),
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
        return OtpScreen(email: email);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return RestaurantShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const LiveOrdersPage(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
