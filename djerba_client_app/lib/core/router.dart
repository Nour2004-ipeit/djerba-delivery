import 'package:go_router/go_router.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/auth/presentation/verification_screens.dart';
import '../features/client/presentation/client_dashboard.dart';
import '../features/client/presentation/restaurant_detail_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/cart/presentation/checkout_screen.dart';
import '../features/cart/presentation/order_tracking_screen.dart';
import '../features/cart/presentation/address_picker_screen.dart';
import '../features/client/presentation/favorites_screen.dart';
import '../features/client/presentation/edit_profile_screen.dart';
import '../features/client/presentation/addresses_screen.dart';
import '../features/client/presentation/language_screen.dart';
import '../features/client/presentation/payment_methods_screen.dart';
import '../features/client/presentation/vouchers_screen.dart';
import '../features/client/presentation/help_support_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
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
    GoRoute(
      path: '/client_dashboard',
      builder: (context, state) => const ClientDashboard(),
    ),
    GoRoute(
      path: '/restaurant_detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return RestaurantDetailScreen(
          id: extra['id'] as String? ?? '',
          name: extra['name'] as String? ?? 'Restaurant',
          imageUrl: extra['imageUrl'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/address_picker',
      builder: (context, state) => const AddressPickerScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/tracking',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return OrderTrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: '/languages',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/payment_methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/vouchers',
      builder: (context, state) => const VouchersScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
  ],
);
