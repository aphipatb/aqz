import 'dart:math';
import 'package:flutter/material.dart';
import '../data/coupon_manager.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

enum PaymentMethodType { cash, promptPay, trueMoney, shopeePay, rabbitLinePay }

extension PaymentMethodTypeX on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.cash:
        return S.payCash;
      case PaymentMethodType.promptPay:
        return S.payPromptPay;
      case PaymentMethodType.trueMoney:
        return S.payTrueMoney;
      case PaymentMethodType.shopeePay:
        return S.payShopeePay;
      case PaymentMethodType.rabbitLinePay:
        return 'Rabbit LINE Pay';
    }
  }
}

enum DispenseOutcome { success, jamRefunded, jamCoupon }

class DispenseResult {
  final Product product;
  final DispenseOutcome outcome;
  final String? couponCode;
  DispenseResult({required this.product, required this.outcome, this.couponCode});
}

class DispenseScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final PaymentMethodType paymentMethod;
  final int amountPaid;
  final int changeToReturn;

  const DispenseScreen({
    super.key,
    required this.cart,
    required this.paymentMethod,
    required this.amountPaid,
    this.changeToReturn = 0,
  });

  @override
  State<DispenseScreen> createState() => _DispenseScreenState();
}

class _DispenseScreenState extends State<DispenseScreen> {
  final _rand = Random();
  final List<DispenseResult> _results = [];
  late final List<Product> _units;
  int _currentIndex = 0;
  bool _done = false;

  static const double _jamProbability = 0.18;

  @override
  void initState() {
    super.initState();
    _units = widget.cart.values
        .expand((item) => List.filled(item.quantity, item.product))
        .toList();
    _dispenseNext();
  }

  Future<void> _dispenseNext() async {
    if (_currentIndex >= _units.length) {
      setState(() => _done = true);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final product = _units[_currentIndex];
    final jammed = _rand.nextDouble() < _jamProbability;

    DispenseResult result;
    if (!jammed) {
      result = DispenseResult(product: product, outcome: DispenseOutcome.success);
    } else {
      final refundInstead = _rand.nextBool();
      if (refundInstead) {
        result = DispenseResult(product: product, outcome: DispenseOutcome.jamRefunded);
      } else {
        final code = _generateCouponCode();
        // ลงทะเบียนโค้ดนี้กับระบบคูปอง เพื่อให้นำไปกรอกลด 15% ในครั้งถัดไปได้จริง
        CouponManager.instance.issue(code);
        result = DispenseResult(
            product: product, outcome: DispenseOutcome.jamCoupon, couponCode: code);
      }
    }

    setState(() {
      _results.add(result);
      _currentIndex++;
    });
    _dispenseNext();
  }

  String _generateCouponCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code =
        List.generate(6, (_) => chars[_rand.nextInt(chars.length)]).join();
    return 'PARTY-$code';
  }

  int get _refundedAmount => _results
      .where((r) => r.outcome == DispenseOutcome.jamRefunded)
      .fold(0, (sum, r) => sum + r.product.price);

  List<String> get _couponCodes => _results
      .where((r) => r.outcome == DispenseOutcome.jamCoupon)
      .map((r) => r.couponCode!)
      .toList();

  int get _netCharged => widget.amountPaid - _refundedAmount;

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
          automaticallyImplyLeading: false,
          title: Text(
            _done ? S.dispenseSummaryTitle : S.dispensingTitle,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              if (!_done)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(
                    value: _units.isEmpty ? 0 : _currentIndex / _units.length,
                    backgroundColor: AppColors.bgCardAlt,
                    color: AppColors.accentTeal,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ResultTile(result: _results[i]),
                ),
              ),
              if (_done)
                _SummaryPanel(
                  paymentMethod: widget.paymentMethod,
                  amountPaid: widget.amountPaid,
                  refunded: _refundedAmount,
                  netCharged: _netCharged,
                  changeToReturn: widget.changeToReturn,
                  couponCodes: _couponCodes,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final DispenseResult result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String message;

    switch (result.outcome) {
      case DispenseOutcome.success:
        icon = Icons.check_circle_rounded;
        color = AppColors.accentTeal;
        message = S.dispenseSuccessMsg;
        break;
      case DispenseOutcome.jamRefunded:
        icon = Icons.replay_circle_filled_rounded;
        color = AppColors.accentRed;
        message = S.dispenseJamRefundMsg;
        break;
      case DispenseOutcome.jamCoupon:
        icon = Icons.confirmation_number_rounded;
        color = AppColors.accentAmber;
        message = S.dispenseJamCouponMsg(result.couponCode ?? '');
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final PaymentMethodType paymentMethod;
  final int amountPaid;
  final int refunded;
  final int netCharged;
  final int changeToReturn;
  final List<String> couponCodes;

  const _SummaryPanel({
    required this.paymentMethod,
    required this.amountPaid,
    required this.refunded,
    required this.netCharged,
    required this.changeToReturn,
    required this.couponCodes,
  });

  @override
  Widget build(BuildContext context) {
    final isCash = paymentMethod == PaymentMethodType.cash;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(S.summaryTotalPaid, '$amountPaid ฿'),
          if (refunded > 0)
            _row(S.summaryRefunded, '-$refunded ฿', color: AppColors.accentRed),
          if (refunded > 0) _row(S.summaryNet, '$netCharged ฿', bold: true),
          if (isCash && changeToReturn > 0)
            _row(S.summaryChangeCash, '$changeToReturn ฿', color: AppColors.accentAmber),
          if (isCash && refunded > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                S.summaryCashNote,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          if (!isCash && refunded > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                S.summaryDigitalNote,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          if (couponCodes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(S.summaryCouponsHeader,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: couponCodes
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentAmber),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                color: AppColors.accentAmber,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(S.doneButton,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
