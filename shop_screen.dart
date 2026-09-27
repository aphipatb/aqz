import 'package:flutter/material.dart';
import '../data/products_data.dart';
import '../i18n/app_language.dart';
import '../i18n/strings.dart';
import '../widgets/language_switcher.dart';
import '../data/stock_manager.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/idle_reset_gate.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'report_issue_screen.dart';

class ShopScreen extends StatefulWidget {
  final dynamic initialMode;
  const ShopScreen({super.key, this.initialMode});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, CartItem> _cart = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: ProductCategory.values.length, vsync: this);
    // ตั้งค่าสต็อกเริ่มต้นของสินค้าทั้งหมด (ทำครั้งเดียว ถ้าเคย init แล้วจะข้าม)
    StockManager.instance.init(allProducts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // กดปุ่ม "+" บนการ์ดสินค้า = จองสต็อก 1 ชิ้น แล้วเพิ่มลงตะกร้า
  // ถ้าสต็อกหมดพอดี (เผื่อกดพร้อมกันหลายจุด) จะไม่เพิ่มให้
  void _addToCart(Product p) {
    final reserved = StockManager.instance.reserveOne(p.id);
    if (!reserved) return;
    setState(() {
      _cart.update(
        p.id,
        (item) {
          item.quantity++;
          return item;
        },
        ifAbsent: () => CartItem(product: p),
      );
    });
  }

  // กดปุ่ม "-" บนการ์ดสินค้า = ลดจำนวน คืนสต็อกที่จองไว้กลับ
  // ถ้าเหลือ 0 จะเอาออกจากตะกร้าให้เอง
  void _removeFromCart(Product p) {
    final item = _cart[p.id];
    if (item == null) return;
    StockManager.instance.releaseOne(p.id);
    setState(() {
      item.quantity--;
      if (item.quantity <= 0) {
        _cart.remove(p.id);
      }
    });
  }

  int get _cartCount =>
      _cart.values.fold(0, (sum, item) => sum + item.quantity);

  int get _cartTotal =>
      _cart.values.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: currentLanguage,
      builder: (context, lang, __) => IdleResetGate(
      // ไม่มีการใช้งาน 45 วิ -> เคลียร์ตะกร้า คืนสต็อกที่จองไว้ แล้วเด้งกลับหน้าแรก
      onBeforeReset: () => StockManager.instance.releaseCart(_cart),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          title: Text(S.shopAppBarTitle,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: LanguageSwitcherButton(),
            ),
            IconButton(
              tooltip: S.reportIssueLabel,
              icon: const Icon(Icons.report_problem_outlined,
                  color: AppColors.textSecondary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const ReportIssueScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.accentRose,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textFaint,
            tabs: ProductCategory.values
                .map((c) => Tab(icon: Icon(c.icon, size: 18), text: c.label))
                .toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: ProductCategory.values.map((cat) {
            final items = allProducts.where((p) => p.category == cat).toList();
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final p = items[i];
                final inCart = _cart[p.id]?.quantity ?? 0;
                return ProductCard(
                  product: p,
                  quantityInCart: inCart,
                  stockAvailable: StockManager.instance.available(p.id),
                  onAdd: () => _addToCart(p),
                  onRemove: () => _removeFromCart(p),
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: _cartCount == 0
            ? null
            : FloatingActionButton.extended(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.shopping_bag_rounded),
                label: Text(S.cartFabLabel(_cartCount, _cartTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cart: _cart,
                        onAdd: (p) => _addToCart(p),
                        onRemove: (p) => _removeFromCart(p),
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
      ),
    ));
  }
}
