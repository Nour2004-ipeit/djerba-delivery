import 'package:flutter/foundation.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  
  factory LocalizationService() {
    return _instance;
  }
  
  LocalizationService._internal();

  String _currentLanguageCode = 'fr'; // 'fr', 'ar', 'en'

  String get currentLanguageCode => _currentLanguageCode;

  void setLanguage(String code) {
    if (['fr', 'ar', 'en'].contains(code)) {
      _currentLanguageCode = code;
      notifyListeners();
    }
  }

  // Dictionaries
  final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'profile_tab': 'Profil',
      'search_tab': 'Rechercher un restaurant...',
      'orders_tab': 'Commandes',
      'home_tab': 'Accueil',
      'favorites_tab': 'Favoris',
      'personal_info': 'Informations personnelles',
      'my_favorites': 'Favoris',
      'my_addresses': 'Adresses enregistrées',
      'payment_methods': 'Mode de paiement',
      'order_history': 'Historique des commandes',
      'languages': 'Langues',
      'settings': 'Paramètres',
      'help_support': 'Aide & informations',
      'about': 'À propos',
      'logout': 'Se déconnecter',
      'popular_restaurants': 'Tous les restaurants',
      'results': '56 résultats',
      'sort_by': 'Trier par',
      'all': 'Tous',
      'tunisian': 'Tunisien',
      'pizza': 'Pizza',
      'fast_food': 'Fast Food',
      'special_offer': 'Offre spéciale',
      'delivery_fee': 'Livraison 2 DT',
      'edit_profile': 'Modifier le profil',
      'free_delivery': 'Livraison gratuite\nce weekend',
      'promo_subtitle': 'Profitez-en du 17 au 19 mai\nsur toutes vos commandes',
      'see_offers': 'Voir les offres',
      'see_all': 'Voir tout',
      'onboarding_slogan': 'Vos envies, livrées à Djerba',
      'onboarding_title': 'Commandez facilement\nvos plats préférés',
      'onboarding_subtitle': 'Livraison rapide à Midoun, Houmt Souk\net partout à Djerba',
      'onboarding_feature1_title': 'Vos restos préférés',
      'onboarding_feature1_desc': 'Un large choix de restaurants locaux',
      'onboarding_feature2_title': 'Suivi en temps réel',
      'onboarding_feature2_desc': 'Suivez votre livreur sur la carte',
      'onboarding_feature3_title': 'Paiement sécurisé',
      'onboarding_feature3_desc': 'Plusieurs options de paiement',
      'onboarding_start': 'Commencer',
      'onboarding_choose_lang': 'Choisir la langue',
    },
    'ar': {
      'profile_tab': 'الملف الشخصي',
      'search_tab': 'ابحث عن مطعم...',
      'orders_tab': 'الطلبات',
      'home_tab': 'الرئيسية',
      'favorites_tab': 'المفضلة',
      'personal_info': 'المعلومات الشخصية',
      'my_favorites': 'المفضلة',
      'my_addresses': 'عناويني المحفوظة',
      'payment_methods': 'طرق الدفع',
      'order_history': 'سجل الطلبات',
      'languages': 'اللغات',
      'settings': 'الإعدادات',
      'help_support': 'المساعدة والمعلومات',
      'about': 'حول',
      'logout': 'تسجيل الخروج',
      'popular_restaurants': 'جميع المطاعم',
      'results': '56 نتيجة',
      'sort_by': 'ترتيب حسب',
      'all': 'الكل',
      'tunisian': 'تونسي',
      'pizza': 'بيتزا',
      'fast_food': 'وجبات سريعة',
      'special_offer': 'عرض خاص',
      'delivery_fee': 'توصيل 2 د.ت',
      'edit_profile': 'تعديل الملف',
      'free_delivery': 'توصيل مجاني\nهذا الأسبوع',
      'promo_subtitle': 'استفد من 17 إلى 19 مايو\nعلى جميع طلباتك',
      'see_offers': 'رؤية العروض',
      'see_all': 'رؤية الكل',
      'onboarding_slogan': 'رغباتك، تصلك في جربة',
      'onboarding_title': 'اطلب بسهولة\nأطباقك المفضلة',
      'onboarding_subtitle': 'توصيل سريع إلى ميدون، حومة السوق\nوفي جميع أنحاء جربة',
      'onboarding_feature1_title': 'مطاعمك المفضلة',
      'onboarding_feature1_desc': 'مجموعة واسعة من المطاعم المحلية',
      'onboarding_feature2_title': 'تتبع في الوقت الفعلي',
      'onboarding_feature2_desc': 'تتبع عامل التوصيل على الخريطة',
      'onboarding_feature3_title': 'دفع آمن',
      'onboarding_feature3_desc': 'خيارات دفع متعددة',
      'onboarding_start': 'ابدأ',
      'onboarding_choose_lang': 'اختر اللغة',
    },
    'en': {
      'profile_tab': 'Profile',
      'search_tab': 'Search a restaurant...',
      'orders_tab': 'Orders',
      'home_tab': 'Home',
      'favorites_tab': 'Favorites',
      'personal_info': 'Personal Information',
      'my_favorites': 'Favorites',
      'my_addresses': 'Saved Addresses',
      'payment_methods': 'Payment Methods',
      'order_history': 'Order History',
      'languages': 'Languages',
      'settings': 'Settings',
      'help_support': 'Help & Info',
      'about': 'About',
      'logout': 'Logout',
      'popular_restaurants': 'All Restaurants',
      'results': '56 results',
      'sort_by': 'Sort by',
      'all': 'All',
      'tunisian': 'Tunisian',
      'pizza': 'Pizza',
      'fast_food': 'Fast Food',
      'special_offer': 'Special Offer',
      'delivery_fee': 'Delivery 2 DT',
      'edit_profile': 'Edit Profile',
      'free_delivery': 'Free delivery\nthis weekend',
      'promo_subtitle': 'Enjoy it from May 17 to 19\non all your orders',
      'see_offers': 'See offers',
      'see_all': 'See all',
      'onboarding_slogan': 'Your cravings, delivered in Djerba',
      'onboarding_title': 'Easily order\nyour favorite meals',
      'onboarding_subtitle': 'Fast delivery in Midoun, Houmt Souk\nand all over Djerba',
      'onboarding_feature1_title': 'Your favorite spots',
      'onboarding_feature1_desc': 'A wide choice of local restaurants',
      'onboarding_feature2_title': 'Real-time tracking',
      'onboarding_feature2_desc': 'Track your driver on the map',
      'onboarding_feature3_title': 'Secure payment',
      'onboarding_feature3_desc': 'Multiple payment options',
      'onboarding_start': 'Get Started',
      'onboarding_choose_lang': 'Choose language',
    },
  };

  String translate(String key) {
    return _localizedValues[_currentLanguageCode]?[key] ?? key;
  }
}
