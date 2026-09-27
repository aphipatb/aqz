import 'dart:async';
import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';

/// ==========================================================================
/// ระบบ Auto-Reset เมื่อไม่มีการใช้งาน (Idle Timeout)
/// ------------------------------------------------------------------------
/// ห่อหน้าจอ (หน้าเลือกสินค้า/ตะกร้า) ด้วยวิดเจ็ตนี้ เพื่อจับว่าเครื่องถูก
/// ปล่อยว่างไว้นานแค่ไหน ถ้าไม่มีการแตะจอเลยครบตามเวลาที่กำหนด (ค่าเริ่มต้น
/// 45 วินาที) จะเด้งกลับไปหน้าแรกอัตโนมัติให้เอง (popUntil isFirst) ซึ่งจะทำ
/// ให้ตะกร้าสินค้า (ที่เก็บอยู่ใน state ของ ShopScreen) ถูกทำลายไปพร้อมกัน
/// เท่ากับเคลียร์ตะกร้าอัตโนมัติ ป้องกันลูกค้าคนถัดไปมากดจ่ายเงินต่อจากที่
/// ค้างไว้
///
/// ก่อนรีเซ็ต 10 วินาทีสุดท้าย จะมีแถบเตือนนับถอยหลังโผล่ขึ้นมาให้ลูกค้ารู้ตัว
/// แตะที่ไหนก็ได้บนจอเพื่อยกเลิกการรีเซ็ต (นับเวลาใหม่ทันที)
///
/// onBeforeReset: callback เสริม เรียกก่อน pop กลับหน้าแรกเสมอ ใช้สำหรับ
/// ให้หน้าที่เรียกใช้ทำความสะอาดข้อมูลเพิ่มเติม เช่น คืนสต็อกสินค้าที่จองไว้
/// ในตะกร้ากลับเข้าระบบ (ดูตัวอย่างการใช้งานใน shop_screen.dart)
/// ==========================================================================
class IdleResetGate extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final Duration warningBefore;
  final VoidCallback? onBeforeReset;

  const IdleResetGate({
    super.key,
    required this.child,
    this.timeout = const Duration(seconds: 45),
    this.warningBefore = const Duration(seconds: 10),
    this.onBeforeReset,
  });

  @override
  State<IdleResetGate> createState() => _IdleResetGateState();
}

class _IdleResetGateState extends State<IdleResetGate> {
  Timer? _ticker;
  late int _secondsLeft = widget.timeout.inSeconds;
  bool _resetTriggered = false;
  bool _wasCurrent = true;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _resetTriggered) return;

      // ถ้าหน้านี้ไม่ได้อยู่บนสุด (เช่น ถูกเปิดหน้าตะกร้าทับอยู่) ให้ "พัก"
      // การนับถอยหลังไว้ก่อน กันไม่ให้มีตัวจับเวลาหลายอันทำงานซ้อนกันแล้ว
      // สั่งรีเซ็ตซ้ำซ้อน/คืนสต็อกซ้ำ
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrent) {
        _wasCurrent = false;
        return;
      }
      if (!_wasCurrent) {
        // เพิ่งกลับมาเป็นหน้าบนสุดอีกครั้ง (เช่น กดย้อนกลับจากตะกร้า) -> เริ่มนับใหม่
        _wasCurrent = true;
        setState(() => _secondsLeft = widget.timeout.inSeconds);
        return;
      }

      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _triggerReset();
      }
    });
  }

  void _registerActivity(PointerDownEvent _) {
    if (_resetTriggered) return;
    if (_secondsLeft != widget.timeout.inSeconds) {
      setState(() => _secondsLeft = widget.timeout.inSeconds);
    }
  }

  void _triggerReset() {
    if (_resetTriggered) return;
    _resetTriggered = true;
    _ticker?.cancel();
    widget.onBeforeReset?.call();
    // เด้งกลับหน้าแรกทั้งหมด (ตะกร้า/ข้อมูลระหว่างเลือกซื้อจะถูกทิ้งไปพร้อมกัน)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showWarning = _secondsLeft <= widget.warningBefore.inSeconds;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _registerActivity,
      child: Stack(
        children: [
          widget.child,
          if (showWarning)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _IdleWarningBanner(secondsLeft: _secondsLeft.clamp(0, 999)),
            ),
        ],
      ),
    );
  }
}

class _IdleWarningBanner extends StatelessWidget {
  final int secondsLeft;
  const _IdleWarningBanner({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, __) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.accentAmber,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    S.idleWarning(secondsLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  S.idleWarningCancelHint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
