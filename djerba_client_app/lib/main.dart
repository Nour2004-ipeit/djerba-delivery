import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await Firebase.initializeApp();
  //   await PushNotificationService.initialize();
  // } catch (e) {
  //   print('Firebase initialization failed (run flutterfire configure): $e');
  // }

  runApp(
    const ProviderScope(
      child: DjerbaDeliveryApp(),
    ),
  );
}

class DjerbaDeliveryApp extends StatelessWidget {
  const DjerbaDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService(),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Djerba Delivery',
          theme: DjerbaTheme.lightTheme,
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
