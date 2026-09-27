import 'app_language.dart';

/// ==========================================================================
/// คลังข้อความ 3 ภาษา (ไทย / English / 中文) ของทั้งแอป
/// ------------------------------------------------------------------------
/// เรียกใช้ผ่าน S.xxx ได้จากทุกไฟล์ เช่น Text(S.cartTitle)
/// ค่าที่คืนจะเปลี่ยนตาม currentLanguage.value อัตโนมัติ ตราบใดที่ widget
/// ที่เรียกใช้อยู่ภายใต้ ValueListenableBuilder<AppLanguage> (ดู app_language.dart)
///
/// หมายเหตุ: ชื่อสินค้า/แบรนด์ (products_data.dart) ไม่ได้แปลในไฟล์นี้
/// เพราะเป็นชื่อสินค้าจริงที่ติดฉลากภาษาไทย/อังกฤษปนกันอยู่แล้ว
/// ==========================================================================
class S {
  S._();

  static AppLanguage get _lang => currentLanguage.value;

  static String _pick({required String th, required String en, required String zh}) {
    switch (_lang) {
      case AppLanguage.en:
        return en;
      case AppLanguage.zh:
        return zh;
      case AppLanguage.th:
        return th;
    }
  }

  // ---------- ตัวเลือกภาษา ----------
  static String get languagePickerTitle => _pick(th: 'เลือกภาษา', en: 'Select Language', zh: '选择语言');

  // ---------- หน้า Idle ----------
  static String get idleTitle => _pick(th: 'ตู้ปาร์ตี้', en: 'Party Vending', zh: '派对自动售货机');
  static String get idleTapToStart =>
      _pick(th: 'แตะหน้าจอเพื่อเลือกสินค้า', en: 'Tap screen to start', zh: '点击屏幕开始选购');
  static String get reportIssueLabel => _pick(th: 'แจ้งปัญหา', en: 'Report Issue', zh: '报告问题');

  // ---------- หมวดหมู่สินค้า ----------
  static String get categoryRecovery =>
      _pick(th: 'กู้ร่าง & แก้แฮงค์', en: 'Hangover Recovery', zh: '解酒恢复');
  static String get categoryFashion =>
      _pick(th: 'แฟชั่นฉุกเฉิน', en: 'Fashion Emergency', zh: '时尚急救');
  static String get categoryFreshness =>
      _pick(th: 'ดับกลิ่น & รีเฟรช', en: 'Freshen Up', zh: '除味清新');
  static String get categoryTech => _pick(th: 'เอาชีวิตรอด', en: 'Survival Gear', zh: '生存装备');

  // ---------- หน้าเลือกสินค้า (Shop) ----------
  static String get shopAppBarTitle =>
      _pick(th: 'แตะ + / - เพื่อเพิ่ม-ลดสินค้า', en: 'Tap + / - to add or remove', zh: '点击 + / - 增减商品');
  static String stockRemaining(int n) =>
      _pick(th: 'คงเหลือ $n ชิ้น', en: '$n left', zh: '剩余 $n 件');
  static String get outOfStock => _pick(th: 'สินค้าหมด', en: 'Out of Stock', zh: '已售罄');
  static String cartFabLabel(int count, int total) => _pick(
        th: 'ตะกร้า ($count) · $total ฿',
        en: 'Cart ($count) · $total ฿',
        zh: '购物车 ($count) · $total ฿',
      );

  // ---------- หน้าตะกร้า (Cart) ----------
  static String get cartTitle => _pick(th: 'ตะกร้าของฉัน', en: 'My Cart', zh: '我的购物车');
  static String get cartEmpty =>
      _pick(th: 'ไม่มีสินค้าในตะกร้า', en: 'Your cart is empty', zh: '购物车是空的');
  static String get sectionSelectedItems =>
      _pick(th: 'รายการสินค้าที่เลือก', en: 'Selected Items', zh: '已选商品');
  static String get sectionCoupon => _pick(th: 'โค้ดส่วนลด', en: 'Discount Code', zh: '优惠码');
  static String get couponHint =>
      _pick(th: 'กรอกโค้ดส่วนลด เช่น PARTY15', en: 'Enter code e.g. PARTY15', zh: '输入优惠码，例如 PARTY15');
  static String get couponApply => _pick(th: 'ใช้โค้ด', en: 'Apply', zh: '使用');
  static String get couponCancel => _pick(th: 'ยกเลิก', en: 'Cancel', zh: '取消');
  static String get couponInvalid =>
      _pick(th: 'โค้ดไม่ถูกต้อง หรือถูกใช้ไปแล้ว', en: 'Invalid or already used code', zh: '代码无效或已被使用');
  static String couponAppliedText(String code) => _pick(
        th: 'ใช้โค้ด $code แล้ว - ลด 15%',
        en: 'Code $code applied - 15% off',
        zh: '已使用代码 $code - 立减15%',
      );
  static String get sectionPaymentMethod =>
      _pick(th: 'เลือกช่องทางชำระเงิน', en: 'Select Payment Method', zh: '选择支付方式');

  static String get payCash => _pick(th: 'เงินสด', en: 'Cash', zh: '现金');
  static String get payCashSub =>
      _pick(th: 'หยอดเหรียญ / แบงก์', en: 'Insert coins / bills', zh: '投币/纸币');
  static String get payPromptPay => 'PromptPay';
  static String get payPromptPaySub => _pick(th: 'สแกน QR Code', en: 'Scan QR Code', zh: '扫描二维码');
  static String get payTrueMoney => 'TrueMoney Wallet';
  static String get payTrueMoneySub => _pick(th: 'สแกนผ่านแอป', en: 'Scan via app', zh: '通过应用扫描');
  static String get payShopeePay => 'ShopeePay';
  static String get payShopeePaySub => _pick(th: 'สแกนผ่านแอป', en: 'Scan via app', zh: '通过应用扫描');

  static String totalLabel(int items) =>
      _pick(th: 'รวมทั้งหมด ($items ชิ้น)', en: 'Total ($items items)', zh: '总计（$items 件）');
  static String savedLabel(int amount, String code) => _pick(
        th: 'ประหยัด $amount ฿ (โค้ด $code)',
        en: 'Saved $amount ฿ (code $code)',
        zh: '节省 $amount ฿（代码 $code）',
      );
  static String get payButton => _pick(th: 'ชำระเงิน', en: 'Pay', zh: '付款');

  // ---------- หน้าป็อปอัป QR (จ่ายผ่านแอป) ----------
  static String get qrTitle => _pick(th: 'สแกน QR Code เพื่อชำระเงิน', en: 'Scan QR Code to Pay', zh: '扫描二维码付款');
  static String get amountDueLabel => _pick(th: 'ยอดที่ต้องชำระ', en: 'Amount Due', zh: '应付金额');
  static String qrExpireIn(int seconds) =>
      _pick(th: 'QR จะหมดอายุใน $seconds วินาที', en: 'QR expires in $seconds sec', zh: '二维码将在 $seconds 秒后失效');
  static String get qrExpired =>
      _pick(th: 'QR หมดอายุแล้ว กรุณาลองใหม่', en: 'QR expired, please try again', zh: '二维码已过期，请重试');
  static String get qrRetryButton => _pick(th: 'สแกนใหม่', en: 'Retry', zh: '重新扫描');
  static String get qrPaidButton => _pick(th: 'ฉันจ่ายเงินแล้ว', en: "I've Paid", zh: '我已付款');
  static String get qrCancelButton => _pick(th: 'ยกเลิก', en: 'Cancel', zh: '取消');

  // ---------- หน้าหยอดเงินสด ----------
  static String get cashTitle => _pick(th: 'หยอดเงินสด', en: 'Insert Cash', zh: '投入现金');
  static String get cashInserted => _pick(th: 'หยอดแล้ว', en: 'Inserted', zh: '已投入');
  static String get cashChange => _pick(th: 'เงินทอน', en: 'Change', zh: '找零');
  static String get cashRemaining => _pick(th: 'ยังขาดอีก', en: 'Remaining', zh: '还差');
  static String get cashInsertHint =>
      _pick(th: 'แตะเพื่อหยอดธนบัตร/เหรียญ (จำลอง)', en: 'Tap to insert bill/coin (simulated)', zh: '点击投入纸币/硬币（模拟）');
  static String get cashConfirmEnough =>
      _pick(th: 'ยืนยันและรับสินค้า', en: 'Confirm & Get Product', zh: '确认并取货');
  static String get cashConfirmNotEnough =>
      _pick(th: 'กรุณาหยอดเงินให้ครบ', en: 'Please insert enough cash', zh: '请投入足够金额');

  // ---------- หน้าจ่ายสินค้า (Dispense) ----------
  static String get dispensingTitle => _pick(th: 'กำลังจ่ายสินค้า...', en: 'Dispensing...', zh: '正在出货...');
  static String get dispenseSummaryTitle =>
      _pick(th: 'สรุปผลการจ่ายสินค้า', en: 'Dispense Summary', zh: '出货结果总结');
  static String get dispenseSuccessMsg => _pick(
      th: 'จ่ายสำเร็จ - เซนเซอร์ยืนยันสินค้าร่วงแล้ว',
      en: 'Dispensed - sensor confirmed drop',
      zh: '出货成功 - 传感器已确认掉落');
  static String get dispenseJamRefundMsg => _pick(
      th: 'สินค้าติดค้าง - ยกเลิกรายการและคืนเงินอัตโนมัติ',
      en: 'Item jammed - order cancelled & auto-refunded',
      zh: '商品卡住 - 已自动取消并退款');
  static String dispenseJamCouponMsg(String code) => _pick(
        th: 'สินค้าติดค้าง - ออกคูปองชดเชยให้ทันที ($code)',
        en: 'Item jammed - compensation coupon issued ($code)',
        zh: '商品卡住 - 已发放补偿优惠券（$code）',
      );
  static String get summaryTotalPaid => _pick(th: 'ยอดชำระทั้งหมด', en: 'Total Paid', zh: '总支付金额');
  static String get summaryRefunded =>
      _pick(th: 'คืนเงินอัตโนมัติ (สินค้าติดค้าง)', en: 'Auto-Refund (jammed item)', zh: '自动退款（卡住商品）');
  static String get summaryNet =>
      _pick(th: 'ยอดที่ชำระจริงสุทธิ', en: 'Net Amount Charged', zh: '实际扣款金额');
  static String get summaryChangeCash =>
      _pick(th: 'เงินทอนที่ช่องรับเงินทอน', en: 'Change at coin return', zh: '找零口的找零');
  static String get summaryCashNote => _pick(
      th: 'ระบบคืนเหรียญ/ธนบัตรส่วนที่ยกเลิกที่ช่องรับเงินทอนแล้ว',
      en: 'Coins/bills for cancelled items returned at the coin slot',
      zh: '已取消部分的硬币/纸币已从找零口退还');
  static String get summaryDigitalNote => _pick(
      th: 'เงินคืนอัตโนมัติเข้าช่องทางชำระเงินที่ใช้ภายใน 1-3 วันทำการ',
      en: 'Refund auto-processed to your payment method within 1-3 business days',
      zh: '退款将在1-3个工作日内自动退回原支付方式');
  static String get summaryCouponsHeader => _pick(
      th: 'คูปองชดเชยที่ได้รับ (ใช้กรอกลด 15% ในการซื้อครั้งถัดไปได้เลย)',
      en: 'Compensation coupons received (use for 15% off next purchase)',
      zh: '获得的补偿优惠券（可用于下次购买立减15%）');
  static String get doneButton => _pick(th: 'เสร็จสิ้น', en: 'Done', zh: '完成');

  // ---------- หน้าแจ้งปัญหา ----------
  static String get reportTitle => _pick(th: 'แจ้งปัญหาการใช้งาน', en: 'Report an Issue', zh: '报告问题');
  static String get reportHeadline =>
      _pick(th: 'พบปัญหาอะไร แจ้งเราได้เลยครับ 🛠️', en: "What's the issue? Let us know 🛠️", zh: '遇到什么问题？请告诉我们 🛠️');
  static String get reportChooseTopic =>
      _pick(th: 'เลือกหัวข้อปัญหา', en: 'Select Issue Type', zh: '选择问题类型');
  static String get issueProductStuck =>
      _pick(th: 'สินค้าไม่ออก', en: 'Product not dispensed', zh: '商品未出货');
  static String get issueChangeIncomplete =>
      _pick(th: 'เงินทอนไม่ครบ', en: 'Incomplete change', zh: '找零不足');
  static String get issueAppFrozen => _pick(th: 'แอปพลิเคชันค้าง', en: 'App frozen', zh: '应用程序卡住');
  static String get issueOther => _pick(th: 'อื่นๆ', en: 'Other', zh: '其他');
  static String get reportDetailLabel =>
      _pick(th: 'รายละเอียดเพิ่มเติม', en: 'Additional Details', zh: '详细说明');
  static String get reportDetailHint =>
      _pick(th: 'อธิบายปัญหาที่พบเพิ่มเติม...', en: 'Describe the issue in more detail...', zh: '请详细描述问题...');
  static String get reportPhoneLabel => _pick(
      th: 'เบอร์โทรศัพท์ติดต่อกลับ / รับเงินคืน', en: 'Callback / Refund Phone Number', zh: '联系电话/退款电话');
  static String get reportConfirmButton =>
      _pick(th: 'ยืนยันการแจ้งปัญหา', en: 'Submit Report', zh: '提交报告');
  static String get reportSuccessSnackbar => _pick(
      th: 'ส่งข้อมูลเรียบร้อยแล้ว ทีมงานจะรีบดำเนินการแก้ไขครับ',
      en: 'Report submitted. Our team will address it shortly.',
      zh: '提交成功，我们的团队将尽快处理。');

  // ---------- แถบเตือน Idle Timeout ----------
  static String idleWarning(int seconds) => _pick(
        th: 'ไม่มีการใช้งาน ระบบจะกลับหน้าแรกและเคลียร์ตะกร้าใน $seconds วิ',
        en: 'No activity - resetting to home and clearing cart in $seconds sec',
        zh: '无操作，系统将在 $seconds 秒后返回首页并清空购物车',
      );
  static String get idleWarningCancelHint =>
      _pick(th: 'แตะเพื่อยกเลิก', en: 'Tap to cancel', zh: '点击取消');
}
