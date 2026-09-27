import 'package:flutter/material.dart';
import '../data/product_images.dart';
import '../i18n/strings.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final int stockAvailable; // สินค้าที่ยังกดเพิ่มได้จริง (หักที่จองในตะกร้าคนอื่นแล้ว)
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.stockAvailable,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final inCart = quantityInCart > 0;
    final outOfStock = stockAvailable <= 0;
    final lowStock = !outOfStock && stockAvailable <= 3;

    return Opacity(
      opacity: outOfStock ? 0.55 : 1,
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: outOfStock,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: inCart ? AppColors.accentPurple : AppColors.divider,
                  width: inCart ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: inCart
                        ? AppColors.accentPurple.withOpacity(0.12)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ProductImage(product: product)),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price} ฿',
                        style: const TextStyle(
                          color: AppColors.accentPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        outOfStock ? S.outOfStock : S.stockRemaining(stockAvailable),
                        style: TextStyle(
                          color: outOfStock
                              ? AppColors.textFaint
                              : (lowStock ? AppColors.accentAmber : AppColors.textFaint),
                          fontSize: 10.5,
                          fontWeight: lowStock ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _QtyControls(quantity: quantityInCart, onAdd: onAdd, onRemove: onRemove),
                ],
              ),
            ),
          ),

          // ป้าย "สินค้าหมด" ทับตรงกลางการ์ด เมื่อสต็อกเหลือ 0
          if (outOfStock)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    S.outOfStock,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Product product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final url = imageUrlFor(product.id);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.bgCardAlt,
        alignment: Alignment.center,
        // ใช้ BoxFit.cover ให้รูปเต็มกรอบพอดีเสมอ ไม่เหลือขอบ/แถบว่าง
        // (ของเดิมใช้ contain แล้วมีแถบพื้นหลังโผล่เป็น "ติ่ง" ด้านบน-ล่าง)
        child: url == null
            ? Text(product.emoji, style: const TextStyle(fontSize: 36))
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Text(product.emoji, style: const TextStyle(fontSize: 36));
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentPurple,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _QtyControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QtyControls({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: double.infinity,
        child: _RoundButton(
          icon: Icons.add_rounded,
          background: AppColors.accentPurple,
          iconColor: Colors.white,
          onTap: onAdd,
          expand: true,
        ),
      );
    }
    return Row(
      children: [
        _RoundButton(
          icon: Icons.remove_rounded,
          background: AppColors.bgCardAlt,
          iconColor: AppColors.textPrimary,
          onTap: onRemove,
        ),
        Expanded(
          child: Center(
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        _RoundButton(
          icon: Icons.add_rounded,
          background: AppColors.accentPurple,
          iconColor: Colors.white,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final bool expand;

  const _RoundButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 32,
          width: expand ? double.infinity : 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
