import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/language_switcher.dart';
import 'shop_screen.dart';
import 'report_issue_screen.dart';

class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, _) => Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // พื้นหลังตกแต่งด้วยวงกลมเรืองแสงสไตล์ปาร์ตี้กลางคืน
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPurple.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentTeal.withOpacity(0.08),
              ),
            ),
          ),

          // เนื้อหาหลักตรงกลาง
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/disco_ball.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Text('🪩', style: TextStyle(fontSize: 120)),
                  ),
                  const SizedBox(height: 28),
                  
                  Text(
                    S.idleTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  const Text(
                    'Night Out & Hangover Rescue',
                    style: TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 70),
                  
                  // ปุ่มแตะสัมผัสดีไซน์นีออนบนพื้นขาว
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: AppColors.accentPurple.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPurple.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: AppColors.accentPurple, size: 30),
                        const SizedBox(width: 14),
                        Text(
                          S.idleTapToStart,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ปุ่มแจ้งปัญหา (มุมซ้ายบน)
          Positioned(
            top: 40,
            left: 24,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                );
              },
              icon: const Icon(Icons.warning_amber_rounded, color: AppColors.accentRose, size: 20),
              label: Text(S.reportIssueLabel, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.bgCard,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),

          // ปุ่มเปลี่ยนภาษา (มุมขวาบน) - รองรับลูกค้าต่างชาติ
          const Positioned(
            top: 40,
            right: 24,
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      ),
    );
  }
}
