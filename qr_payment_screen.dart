import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/language_switcher.dart';
import 'dispense_screen.dart';

/// ==========================================================================
/// หน้าป็อปอัป QR Code จำลอง สำหรับช่องทางจ่ายผ่านแอป
/// (PromptPay / TrueMoney Wallet / ShopeePay / Rabbit LINE Pay)
/// ------------------------------------------------------------------------
/// - โชว์ QR Code ปลอมๆ (สร้างจาก API สร้าง QR ฟรี ไม่ได้ผูกระบบจ่ายเงินจริง)
///   พร้อมยอดที่ต้องชำระ
/// - นับถอยหลัง 45 วินาที เหมือน QR จ่ายเงินจริงที่หมดอายุได้ ถ้าหมดเวลา
///   ก่อนกด "ฉันจ่ายเงินแล้ว" ระบบจะถือว่า QR หมดอายุ ต้องกด "สแกนใหม่"
///   เพื่อขอ QR ใบใหม่ (นับเวลาใหม่)
/// - ในของจริงจุดนี้จะเป็นตอนที่เครื่อง POS ตรวจสอบผลชำระเงินจากธนาคาร/
///   วอลเล็ตอัตโนมัติ แต่เพราะแอปนี้เป็นการจำลอง จึงใช้ปุ่ม "ฉันจ่ายเงินแล้ว"
///   แทนการยืนยันจากฝั่งลูกค้าเอง
/// ==========================================================================
class QrPaymentScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final PaymentMethodType paymentMethod;
  final int amountPaid;

  const QrPaymentScreen({
    super.key,
    required this.cart,
    required this.paymentMethod,
    required this.amountPaid,
  });

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  static const int _timeoutSeconds = 45;
  final _rand = Random();

  int _secondsLeft = _timeoutSeconds;
  Timer? _timer;
  String _qrToken = '';

  @override
  void initState() {
    super.initState();
    _generateNewQr();
    _startTimer();
  }

  void _generateNewQr() {
    // ข้อมูลปลอมๆ ที่เข้ารหัสลง QR แค่ให้ดูเหมือนจริง ไม่ได้ผูกระบบจ่ายเงินจริง
    _qrToken =
        'PARTYVEND|${widget.paymentMethod.name}|${widget.amountPaid}|${_rand.nextInt(999999)}';
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _timeoutSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _timer?.cancel();
      }
    });
  }

  void _retry() {
    setState(() {
      _generateNewQr();
      _startTimer();
    });
  }

  void _confirmPaid() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DispenseScreen(
          cart: widget.cart,
          paymentMethod: widget.paymentMethod,
          amountPaid: widget.amountPaid,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = _secondsLeft <= 0;
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=${Uri.encodeComponent(_qrToken)}';

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, __) => Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgCard,
          elevation: 1,
          shadowColor: Colors.black12,
          title: Text(S.qrTitle,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: LanguageSwitcherButton(),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.paymentMethod.label,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(S.amountDueLabel,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('${widget.amountPaid} ฿',
                    style: const TextStyle(
                        color: AppColors.accentPurple, fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 22),

                // กรอบ QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Opacity(
                    opacity: expired ? 0.25 : 1,
                    child: Image.network(
                      qrUrl,
                      width: 220,
                      height: 220,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                        width: 220,
                        height: 220,
                        child: Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black26),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.accentPurple),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!expired)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.accentAmber, size: 18),
                      const SizedBox(width: 6),
                      Text(S.qrExpireIn(_secondsLeft),
                          style: const TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.w600)),
                    ],
                  )
                else
                  Text(S.qrExpired,
                      style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),

                const SizedBox(height: 26),

                if (expired)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _retry,
                      child: Text(S.qrRetryButton,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _confirmPaid,
                      child: Text(S.qrPaidButton,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.qrCancelButton, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
