import 'package:flutter/material.dart';
import '../data/coupon_manager.dart';
import '../data/product_images.dart';
import '../data/stock_manager.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/idle_reset_gate.dart';
import '../widgets/language_switcher.dart';
import 'cash_payment_screen.dart';
import 'dispense_screen.dart';
import 'qr_payment_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final Function(Product) onAdd;
  final Function(Product) onRemove;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.promptPay;
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  int get _totalAmount => widget.cart.values
      .fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  int get _totalItems =>
      widget.cart.values.fold(0, (sum, item) => sum + item.quantity);

  bool get _hasDiscount => _appliedCoupon != null;

  int get _discountAmount =>
      _hasDiscount ? _totalAmount - CouponManager.instance.applyDiscount(_totalAmount) : 0;

  // ยอดที่ต้องจ่ายจริงหลังหักส่วนลดคูปอง (ถ้ามี) - ใช้ตัวนี้ตอนไปหน้าชำระเงิน
  int get _payableAmount =>
      _hasDiscount ? CouponManager.instance.applyDiscount(_totalAmount) : _totalAmount;

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    if (CouponManager.instance.isValid(code)) {
      // ใช้โค้ดแบบครั้งเดียวทันทีตอนกดใช้ (โค้ดเดโม่ PARTY15/WELCOME15 ใช้ซ้ำได้)
      CouponManager.instance.redeem(code);
      setState(() {
        _appliedCoupon = code.trim().toUpperCase();
        _couponError = null;
      });
    } else {
      setState(() => _couponError = S.couponInvalid);
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponError = null;
      _couponController.clear();
    });
  }

  void _processPayment() {
    if (widget.cart.isEmpty) return;

    if (_selectedMethod == PaymentMethodType.cash) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CashPaymentScreen(
            cart: widget.cart,
            total: _payableAmount,
          ),
        ),
      );
    } else {
      // สำหรับ PromptPay/TrueMoney/ShopeePay: โชว์ป็อปอัป QR Code จำลองก่อน
      // แล้วค่อยไปหน้าจ่ายสินค้าเมื่อกด "ฉันจ่ายเงินแล้ว"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrPaymentScreen(
            cart: widget.cart,
            paymentMethod: _selectedMethod,
            amountPaid: _payableAmount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartList = widget.cart.values.toList();

    return IdleResetGate(
      // ไม่มีการใช้งาน 45 วิ ระหว่างดูตะกร้า -> คืนสต็อกที่จองไว้ แล้วกลับหน้าแรก
      onBeforeReset: () => StockManager.instance.releaseCart(widget.cart),
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: currentLanguage,
        builder: (context, lang, __) => Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.cartTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: widget.cart.isEmpty
          ? Center(
              child: Text(
                S.cartEmpty,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ส่วนที่ 1: รายการสินค้า ---
                        Text(
                          S.sectionSelectedItems,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = cartList[index];
                            return _CartItemTile(
                              item: item,
                              onAdd: () => setState(() => widget.onAdd(item.product)),
                              onRemove: () => setState(() => widget.onRemove(item.product)),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // --- ส่วนที่ 1.5: โค้ดคูปองส่วนลด ---
                        Text(
                          S.sectionCoupon,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CouponBox(
                          controller: _couponController,
                          appliedCode: _appliedCoupon,
                          errorText: _couponError,
                          onApply: _applyCoupon,
                          onRemove: _removeCoupon,
                        ),

                        const SizedBox(height: 28),

                        // --- ส่วนที่ 2: เลือกช่องทางชำระเงิน ---
                        Text(
                          S.sectionPaymentMethod,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _PaymentOptionCard(
                              title: S.payCash,
                              subtitle: S.payCashSub,
                              icon: Icons.payments_rounded,
                              iconColor: const Color(0xFF10B981),
                              isSelected: _selectedMethod == PaymentMethodType.cash,
                              onTap: () => setState(() => _selectedMethod = PaymentMethodType.cash),
                            ),
                            _PaymentOptionCard(
                              title: S.payPromptPay,
                              subtitle: S.payPromptPaySub,
                              icon: Icons.qr_code_2_rounded,
                              iconColor: const Color(0xFF003D6B),
                              isSelected: _selectedMethod == PaymentMethodType.promptPay,
                              onTap: () => setState(() => _selectedMethod = PaymentMethodType.promptPay),
                            ),
                            _PaymentOptionCard(
                              title: S.payTrueMoney,
                              subtitle: S.payTrueMoneySub,
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFFFF5500),
                              isSelected: _selectedMethod == PaymentMethodType.trueMoney,
                              onTap: () => setState(() => _selectedMethod = PaymentMethodType.trueMoney),
                            ),
                            _PaymentOptionCard(
                              title: S.payShopeePay,
                              subtitle: S.payShopeePaySub,
                              icon: Icons.shopping_bag_rounded,
                              iconColor: const Color(0xFFEE4D2D),
                              isSelected: _selectedMethod == PaymentMethodType.shopeePay,
                              onTap: () => setState(() => _selectedMethod = PaymentMethodType.shopeePay),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- ส่วนที่ 3: แถบสรุปเงิน & ปุ่มกดชำระเงินด้านล่าง ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.totalLabel(_totalItems),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (_hasDiscount)
                              Text(
                                '$_totalAmount ฿',
                                style: const TextStyle(
                                  color: AppColors.textFaint,
                                  fontSize: 13,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '$_payableAmount ฿',
                              style: const TextStyle(
                                color: AppColors.accentPurple,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (_hasDiscount)
                              Text(
                                S.savedLabel(_discountAmount, _appliedCoupon ?? ''),
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.accentPurple.withOpacity(0.3),
                              ),
                              onPressed: _processPayment,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    S.payButton,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

// Widget กล่องกรอกโค้ดคูปองส่วนลด
class _CouponBox extends StatelessWidget {
  final TextEditingController controller;
  final String? appliedCode;
  final String? errorText;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponBox({
    required this.controller,
    required this.appliedCode,
    required this.errorText,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (appliedCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF10B981)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                S.couponAppliedText(appliedCode!),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(S.couponCancel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: S.couponHint,
                  hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentPurple, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onApply,
                child: Text(S.couponApply, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText!, style: const TextStyle(color: AppColors.accentRed, fontSize: 12)),
          ),
      ],
    );
  }
}

// Widget แสดงรายการสินค้าในตะกร้า
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrlFor(item.product.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // รูปสินค้า - ใช้ BoxFit.cover เต็มกรอบ ไม่มีแถบขอบว่าง (ติ่ง)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.bgCardAlt,
              alignment: Alignment.center,
              child: url == null
                  ? Text(item.product.emoji, style: const TextStyle(fontSize: 24))
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (_, __, ___) =>
                          Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // ชื่อและราคา
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.product.price} ฿ / ชิ้น',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ปุ่มเพิ่ม/ลดจำนวน
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCardAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textPrimary),
                  onPressed: onRemove,
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.accentPurple),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget ปุ่มตัวเลือกช่องทางชำระเงิน
class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.06) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? iconColor.withOpacity(0.12) : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ไอคอนประจำช่องทาง
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),

            // ข้อความชื่อช่องทาง
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // เครื่องหมายถูกเมื่อเลือก
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: iconColor, size: 20)
            else
              const Icon(Icons.circle_outlined, color: AppColors.divider, size: 20),
          ],
        ),
      ),
    );
  }
}
