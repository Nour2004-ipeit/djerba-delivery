import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'en';

  void setLanguage(String lang) {
    state = lang;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(() {
  return LanguageNotifier();
});

const Map<String, Map<String, String>> translations = {
  'en': {
    'platform_overview': 'Platform Overview',
    'user_management': 'User Management',
    'delivery_tracking': 'Delivery Tracking',
    'marketing_promos': 'Marketing & Promos',
    'support_tickets': 'Support Tickets',
    'settings': 'Settings',
    'logout': 'Logout',
    'search': 'Search users, orders, or restaurants...',
    'admin_user': 'Admin User',
    'super_admin': 'Super Admin',
  },
  'fr': {
    'platform_overview': 'Vue d\'ensemble',
    'user_management': 'Gestion des utilisateurs',
    'delivery_tracking': 'Suivi des livraisons',
    'marketing_promos': 'Marketing & Promos',
    'support_tickets': 'Réclamations',
    'settings': 'Paramètres',
    'logout': 'Déconnexion',
    'search': 'Rechercher des utilisateurs, commandes...',
    'admin_user': 'Administrateur',
    'super_admin': 'Super Admin',
  },
  'ar': {
    'platform_overview': 'نظرة عامة على المنصة',
    'user_management': 'إدارة المستخدمين',
    'delivery_tracking': 'تتبع التوصيل',
    'marketing_promos': 'التسويق والعروض',
    'support_tickets': 'الشكاوى والدعم',
    'settings': 'الإعدادات',
    'logout': 'تسجيل خروج',
    'search': 'البحث عن المستخدمين أو الطلبات...',
    'admin_user': 'مدير النظام',
    'super_admin': 'مدير عام',
  },
};

String translate(String key, String langCode) {
  return translations[langCode]?[key] ?? key;
}
