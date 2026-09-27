/// ==========================================================================
/// ระบบโค้ดคูปองส่วนลด 15%
/// ------------------------------------------------------------------------
/// - โค้ดทดสอบสำหรับใช้เดโม่/แจกทั่วไป (ใช้ได้ไม่จำกัดจำนวนครั้ง): PARTY15, WELCOME15
/// - โค้ดที่ระบบออกให้อัตโนมัติตอนสินค้าติดค้างในหน้า "กำลังจ่ายสินค้า"
///   (ดูที่ screens/dispense_screen.dart) จะถูกบันทึกไว้ในนี้ผ่าน issue()
///   และใช้ได้ครั้งเดียว (ใช้แล้วนำออกจากระบบทันที กันเอาไปใช้ซ้ำ)
/// ==========================================================================
class CouponManager {
  CouponManager._();
  static final CouponManager instance = CouponManager._();

  static const double discountRate = 0.15; // ลด 15%

  // โค้ดตายตัวไว้เดโม่ระบบ ใช้ซ้ำได้ไม่จำกัด
  static const Set<String> _demoCodes = {'PARTY15', 'WELCOME15'};

  // โค้ดที่ออกให้จริงจากเหตุการณ์สินค้าติดค้าง ใช้ได้ครั้งเดียว
  final Set<String> _issuedCodes = {};

  void issue(String code) => _issuedCodes.add(_normalize(code));

  bool isValid(String code) {
    final c = _normalize(code);
    if (c.isEmpty) return false;
    return _demoCodes.contains(c) || _issuedCodes.contains(c);
  }

  /// เรียกตอนใช้โค้ดสำเร็จแล้ว เพื่อตัดสิทธิ์โค้ดแบบใช้ครั้งเดียวออกจากระบบ
  void redeem(String code) {
    final c = _normalize(code);
    if (!_demoCodes.contains(c)) {
      _issuedCodes.remove(c);
    }
  }

  int applyDiscount(int amount) => (amount * (1 - discountRate)).round();

  String _normalize(String code) => code.trim().toUpperCase();
}
