import '../models/product.dart';

/// ==========================================================================
/// ระบบตัดสต็อกแบบเรียลไทม์ (Real-time Stock)
/// ------------------------------------------------------------------------
/// เก็บจำนวนสินค้าคงเหลือของทุกชิ้นไว้ที่เดียว (singleton) เพื่อให้ทุกหน้า
/// (หน้าเลือกสินค้า/ตะกร้า) เห็นตัวเลขสต็อกตรงกันเสมอ
///
/// กติกาการตัดสต็อก:
///   - กด "+" เพิ่มลงตะกร้า -> จองสต็อก 1 ชิ้นทันที (stock ลดลงให้เห็นเลย
///     กันไม่ให้คนถัดไปกดซื้อซ้ำเกินของจริงที่มี)
///   - กด "-" ลด/เอาออกจากตะกร้าก่อนจ่ายเงิน -> คืนสต็อกที่จองไว้กลับ
///   - จ่ายเงิน/จ่ายสินค้าสำเร็จ (หรือแม้สินค้าจะติดค้างในเครื่อง) -> ถือว่า
///     สต็อกชิ้นนั้นถูกใช้ไปจริงแล้ว ไม่คืนกลับ (ของออกจากเครื่องไปแล้ว)
///   - ตะกร้าถูกเคลียร์เพราะ Idle Timeout (ลูกค้าเดินหนี) -> ต้องคืนสต็อก
///     ที่จองไว้ทั้งหมดกลับ เพราะยังไม่มีใครจ่ายเงินจริง
/// ==========================================================================
class StockManager {
  StockManager._();
  static final StockManager instance = StockManager._();

  final Map<String, int> _stock = {};
  bool _initialized = false;

  /// เรียกครั้งเดียวตอนแอปเริ่มทำงาน เพื่อตั้งสต็อกเริ่มต้นจากรายการสินค้า
  void init(List<Product> products) {
    if (_initialized) return;
    for (final p in products) {
      _stock[p.id] = p.initialStock;
    }
    _initialized = true;
  }

  /// จำนวนที่ยังกดเพิ่มลงตะกร้าได้จริง ณ ตอนนี้ (หักส่วนที่จองไว้ในตะกร้าคนอื่นแล้ว)
  int available(String productId) => _stock[productId] ?? 0;

  bool isOutOfStock(String productId) => available(productId) <= 0;

  /// จองสต็อก 1 ชิ้น (ตอนกด "+") คืนค่า false ถ้าของหมดแล้ว (กันตัดสต็อกติดลบ)
  bool reserveOne(String productId) {
    final left = available(productId);
    if (left <= 0) return false;
    _stock[productId] = left - 1;
    return true;
  }

  /// คืนสต็อก 1 ชิ้น (ตอนกด "-" หรือลบออกจากตะกร้าก่อนจ่ายเงิน)
  void releaseOne(String productId) {
    _stock[productId] = available(productId) + 1;
  }

  /// คืนสต็อกทั้งหมดของตะกร้า (ใช้ตอน Idle Timeout เคลียร์ตะกร้าทิ้ง)
  void releaseCart(Map<String, CartItem> cart) {
    for (final item in cart.values) {
      _stock[item.product.id] = available(item.product.id) + item.quantity;
    }
  }
}
