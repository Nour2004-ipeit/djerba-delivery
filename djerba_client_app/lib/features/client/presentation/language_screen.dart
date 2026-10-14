import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/localization_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: ListenableBuilder(
          listenable: LocalizationService(),
          builder: (context, _) {
            return Text(
              LocalizationService().translate('languages'),
              style: const TextStyle(color: DjerbaTheme.textPrimary, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: LocalizationService(),
        builder: (context, _) {
          final currentLang = LocalizationService().currentLanguageCode;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildLanguageOption(
                context: context,
                code: 'fr',
                title: 'Français',
                isSelected: currentLang == 'fr',
              ),
              _buildLanguageOption(
                context: context,
                code: 'ar',
                title: 'العربية (Arabic)',
                isSelected: currentLang == 'ar',
              ),
              _buildLanguageOption(
                context: context,
                code: 'en',
                title: 'English',
                isSelected: currentLang == 'en',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String title,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => LocalizationService().setLanguage(code),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? DjerbaTheme.primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? DjerbaTheme.primaryColor : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? DjerbaTheme.primaryColor : DjerbaTheme.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: DjerbaTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
