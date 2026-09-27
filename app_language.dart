import 'package:flutter/foundation.dart';

/// ภาษาที่ตู้รองรับ: ไทย, English, จีนกลาง (ตัวย่อ)
enum AppLanguage { th, en, zh }

/// สถานะภาษาปัจจุบันของทั้งแอป - เป็น global ตัวเดียว เปลี่ยนที่นี่ที่เดียวพอ
/// หน้าไหนอยากรองรับหลายภาษา ให้ห่อ Scaffold ด้วย
/// ValueListenableBuilder<AppLanguage>(valueListenable: currentLanguage, ...)
/// แล้วดึงข้อความจากคลาส S (ดูที่ lib/i18n/strings.dart) แทนการพิมพ์ข้อความตรงๆ
final ValueNotifier<AppLanguage> currentLanguage =
    ValueNotifier<AppLanguage>(AppLanguage.th);
