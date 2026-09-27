import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';

/// ปุ่มเปลี่ยนภาษา - แสดงธงภาษาปัจจุบัน แตะแล้วเปิดเมนูให้เลือก ไทย/English/中文
/// วางไว้ที่มุมจอของแต่ละหน้า (ดูตัวอย่างการใช้งานใน idle_screen.dart,
/// shop_screen.dart และ cart_screen.dart)
class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Text(
              S.languagePickerTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const _LangTile(flag: '🇹🇭', label: 'ไทย', lang: AppLanguage.th),
            const _LangTile(flag: '🇬🇧', label: 'English', lang: AppLanguage.en),
            const _LangTile(flag: '🇨🇳', label: '中文', lang: AppLanguage.zh),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _flagFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.th:
        return '🇹🇭';
      case AppLanguage.en:
        return '🇬🇧';
      case AppLanguage.zh:
        return '🇨🇳';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_flagFor(lang), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final AppLanguage lang;
  const _LangTile({required this.flag, required this.label, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, current, _) {
        final selected = current == lang;
        return ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 22)),
          title: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.accentPurple)
              : null,
          onTap: () {
            currentLanguage.value = lang;
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
