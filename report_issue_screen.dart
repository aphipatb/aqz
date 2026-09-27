import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/language_switcher.dart';

enum _IssueTopic { productStuck, changeIncomplete, appFrozen, other }

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  _IssueTopic _selectedTopic = _IssueTopic.productStuck;

  String _labelFor(_IssueTopic topic) {
    switch (topic) {
      case _IssueTopic.productStuck:
        return S.issueProductStuck;
      case _IssueTopic.changeIncomplete:
        return S.issueChangeIncomplete;
      case _IssueTopic.appFrozen:
        return S.issueAppFrozen;
      case _IssueTopic.other:
        return S.issueOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, __) => Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgCard,
          elevation: 1,
          shadowColor: Colors.black12,
          title: Text(
            S.reportTitle,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: LanguageSwitcherButton(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.reportHeadline,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Text(S.reportChooseTopic,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _IssueTopic.values.map((topic) {
                  final isSelected = _selectedTopic == topic;
                  return ChoiceChip(
                    label: Text(_labelFor(topic), style: const TextStyle(fontSize: 15)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTopic = topic);
                    },
                    backgroundColor: AppColors.bgCard,
                    selectedColor: AppColors.accentRose.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.accentRose : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.accentRose : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              Text(S.reportDetailLabel,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              TextField(
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: S.reportDetailHint,
                  hintStyle: const TextStyle(color: AppColors.textFaint),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(S.reportPhoneLabel,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              TextField(
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '08X-XXX-XXXX',
                  hintStyle: const TextStyle(color: AppColors.textFaint),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.accentPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppColors.accentPurple.withOpacity(0.4),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.reportSuccessSnackbar),
                        backgroundColor: AppColors.textPrimary,
                      ),
                    );
                  },
                  child: Text(
                    S.reportConfirmButton,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
