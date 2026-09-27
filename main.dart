import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/idle_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // โหมดเต็มหน้าจอสำหรับจอตู้ (kiosk) - ซ่อนแถบสถานะและแถบนำทางของระบบ
  // เพื่อให้ UI แสดงเต็มพื้นที่จอทั้งหมด ไม่มีแถบใดๆ ของ OS มาบัง
  // หมายเหตุ: ถ้าเทสบนมือถือส่วนตัวแล้วอยากดึงแถบระบบกลับมาชั่วคราว
  // ให้ปัดจากขอบจอเข้ามา (แถบจะโผล่มาชั่วคราวแล้วซ่อนไปเองตามพฤติกรรม
  // SystemUiMode.immersiveSticky ของ Android)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const PartyVendingApp());
}

class PartyVendingApp extends StatelessWidget {
  const PartyVendingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ตู้ปาร์ตี้ & กู้ร่างสายสังสรรค์',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        fontFamily: 'Prompt', // แนะนำให้เพิ่มฟอนต์ Prompt/Kanit ในโปรเจกต์จริง
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentRose,
          brightness: Brightness.dark,
        ),
      ),
      // ให้แอปกลับเข้าสู่โหมดเต็มหน้าจออีกครั้งทุกครั้งที่มีการ build ใหม่
      // (กันกรณี OS ดึงแถบระบบกลับมาแสดงหลังสลับแอปไปมา)
      builder: (context, child) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        return child!;
      },
      home: const IdleScreen(),
    );
  }
}
