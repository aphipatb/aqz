/// ==========================================================================
/// ใส่รูปสินค้า "ที่เดียว ง่ายๆ" ตรงนี้ทั้งหมด ไม่ต้องไปหาแก้ไฟล์อื่นเลย
///
/// วิธีใช้: หา URL รูปสินค้า (จะก็อปจากเว็บไหนก็ได้ที่อนุญาตให้ใช้รูป เช่น
/// รูปที่อัปโหลดเองขึ้น Google Drive/Imgur/Firebase หรือรูปสินค้าจาก
/// เว็บที่ขายของ) แล้วเอามาวางแทนที่ '' ของสินค้านั้นๆ ตามชื่อที่คอมเมนต์ไว้
///
/// ตัวอย่าง:
///   'r01': 'https://i.imgur.com/xxxxx.jpg', // เจลแก้แฮงค์
///
/// - ไม่ต้องใส่ครบทุกอันก็ได้ ช่องไหนเว้น '' ไว้ ระบบจะโชว์ emoji แทนให้เอง
/// - แก้ไฟล์นี้ไฟล์เดียว รูปจะเปลี่ยนทั้งในหน้าเลือกสินค้าและหน้าตะกร้าให้อัตโนมัติ
/// ==========================================================================
final Map<String, String> productImageUrls = {
  // ---------- กู้ร่าง & แก้แฮงค์ ----------
  'r01': 'https://medias.watsons.co.th/publishing/WTCTH-298851-swatch-zoom.jpg?version=1716889069', // เจลแก้แฮงค์
  'r02': 'https://medias.watsons.co.th/publishing/WTCTH-321497-side-zoom.jpg?version=1759519218', // วิตามินละลายน้ำ
  'r03': 'https://obs-ect.line-scdn.net/r/ect/ect/image_170824130644231932422dc2720t130dd88a', // แคปซูลขมิ้นชัน/ร่างจืด
  'r04': 'https://st.bigc-cs.com/cdn-cgi/image/format=webp,quality=90/public/media/catalog/product/26/88/8850157100526/8850157100526_1-20260609140317-.jpg', // กัมมี่วิตามินซี
  'r05': 'https://down-th.img.susercontent.com/file/th-11134207-7rasd-m8mdc5l7p1zj77', // บ๊วยเค็มตื่นนอน
  'r06': 'https://assets.unileversolutions.com/v2/w600/ch-retailer/web/PWsIWGehQNqdCuGwQYj6XQ/126326705.jpeg', // ซุปก้อน/โจ๊กคัพ
  'r07': 'https://medias.watsons.co.th/publishing/WTCTH-298828-side-zoom.jpg?version=1716889023', // แผ่นแปะคูลลิ่ง
  'r08': 'https://down-th.img.susercontent.com/file/th-11134207-81ztk-mjgo4ww4uxaa69', // เกลือแร่ผงชง

  // ---------- แฟชั่นฉุกเฉิน ----------
  'f01': 'https://down-th.img.susercontent.com/file/sg-11134207-7rd6y-lwnnnz19t6mi80', // แผ่นรองรองเท้ากัด
  'f02': 'https://medias.watsons.co.th/publishing/WTCTH-326623-side-zoom.jpg?version=1775159476', // เทปกาวแฟชั่น
  'f03': 'https://down-th.img.susercontent.com/file/69523af031eb65f55eacde9fd9c50d32', // สเปรย์สระผมแห้ง (ขวดจิ๋ว)
  'f04': 'https://raw.githubusercontent.com/aphipatb/photo/main/AB-2-2.jpg', // ถุงเท้า/ถุงน่องสำรอง
  'f05': 'https://down-th.img.susercontent.com/file/th-11134207-23010-29muvmcogdmv87', // แผ่นเช็ดคราบเปื้อนฉุกเฉิน
  'f06': 'https://raw.githubusercontent.com/aphipatb/photo/main/GOODY-4MMLagreElasticsBlack-CDS10587560-1.webp', // กิ๊บ/ยางรัดผม

  // ---------- ดับกลิ่น & รีเฟรช ----------
  's01': 'https://raw.githubusercontent.com/aphipatb/photo/main/25.webp', // สเปรย์ดับกลิ่นปาก
  's02': 'https://down-th.img.susercontent.com/file/ac1c3c2d0f41229dcabcdeb83fa30556', // ลูกอมชาร์โคล
  's03': 'https://raw.githubusercontent.com/aphipatb/photo/main/25.webp', // สเปรย์ดับกลิ่นเสื้อผ้า (มินิ)
  's04': 'https://raw.githubusercontent.com/aphipatb/photo/main/11.jpg', // ทิชชู่เปียกสูตรเย็น
  's05': 'https://raw.githubusercontent.com/aphipatb/photo/main/222.jpg', // กระดาษซับหน้ามัน/แป้งจิ๋ว
  's06': 'https://raw.githubusercontent.com/aphipatb/photo/main/333.jpg', // น้ำยาหยอดตา

  // ---------- เอาชีวิตรอด ----------
  't01': 'https://raw.githubusercontent.com/aphipatb/photo/main/444.jpg', // พัดลมพกพาขนาดเล็ก
  't02': 'https://raw.githubusercontent.com/aphipatb/photo/main/555.jpg', // สายชาร์จราคาประหยัด
  't03': 'https://raw.githubusercontent.com/aphipatb/photo/main/777.jpg', // จุกอุดหูตัดเสียง
  't04': 'https://down-th.img.susercontent.com/file/th-11134207-7rasc-m723wihfc2jk7e', // ซองกันน้ำพกพา
};

/// เรียกใช้ฟังก์ชันนี้เพื่อดึง URL รูปของสินค้าตาม id
/// คืนค่า null ถ้ายังไม่ได้ใส่รูป (widget จะ fallback ไปโชว์ emoji แทนเอง)
String? imageUrlFor(String productId) {
  final url = productImageUrls[productId];
  if (url == null || url.trim().isEmpty) return null;
  return url;
}
