import 'package:flutter/material.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/language_switcher.dart';
import 'dispense_screen.dart';
import '../models/product.dart';

class CashPaymentScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final int total;

  const CashPaymentScreen({super.key, required this.cart, required this.total});

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  int _inserted = 0;
  static const _notes = [20, 50, 100, 500, 1000];

  int get _remaining => (widget.total - _inserted).clamp(0, widget.total);
  int get _change => (_inserted - widget.total).clamp(0, 1 << 30);
  bool get _isEnough => _inserted >= widget.total;

  void _insert(int value) {
    setState(() => _inserted += value);
  }

  void _confirm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DispenseScreen(
          cart: widget.cart,
          paymentMethod: PaymentMethodType.cash,
          amountPaid: widget.total,
          changeToReturn: _change,
        ),
      ),
    );
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
          title: Text(S.cashTitle,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: LanguageSwitcherButton(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _AmountRow(label: S.amountDueLabel, value: widget.total),
                    const Divider(height: 24, color: AppColors.divider),
                    _AmountRow(
                      label: S.cashInserted,
                      value: _inserted,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(height: 12),
                    _AmountRow(
                      label: _isEnough ? S.cashChange : S.cashRemaining,
                      value: _isEnough ? _change : _remaining,
                      color: _isEnough ? AppColors.accentAmber : AppColors.accentRose,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(S.cashInsertHint,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _notes.map((v) {
                  return _NoteButton(value: v, onTap: () => _insert(v));
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEnough ? AppColors.accentTeal : AppColors.bgElevated,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _isEnough ? 4 : 0,
                  ),
                  onPressed: _isEnough ? _confirm : null,
                  child: Text(
                    _isEnough ? S.cashConfirmEnough : S.cashConfirmNotEnough,
                    style: TextStyle(
                      color: _isEnough ? Colors.white : AppColors.textFaint,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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

class _AmountRow extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;
  const _AmountRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
        Text('$value ฿',
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}

class _NoteButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;
  const _NoteButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 90,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentPurple.withOpacity(0.2)),
          ),
          child: Text('$value ฿',
              style: const TextStyle(
                  color: AppColors.accentPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
      ),
    );
  }
}
