import 'package:flutter/material.dart';
import '../i18n/strings.dart';

/// โหมดการใช้งาน
enum PartyMode {
  preParty, // สายพร้อมลุย
  hangover, // สายกู้ร่าง
}

/// เพิ่มส่วนขยาย (Extension) ให้ PartyMode มีค่า label, subtitle, และ color
extension PartyModeX on PartyMode {
  String get label {
    switch (this) {
      case PartyMode.preParty:
        return 'สายพร้อมลุย (Pre-Party)';
      case PartyMode.hangover:
        return 'สายกู้ร่าง / แก้แฮงค์ (Hangover)';
    }
  }

  String get subtitle {
    switch (this) {
      case PartyMode.preParty:
        return 'เตรียมพร้อมก่อนท่องราตรี เติมพลัง เติมเสน่ห์';
      case PartyMode.hangover:
        return 'ตื่นมาแล้วหัวหมุน ร่างพัง ต้องการการฟื้นฟูด่วน';
    }
  }

  Color get color {
    switch (this) {
      case PartyMode.preParty:
        return const Color(0xFF8B5CF6); // สีม่วงพรีเมียม
      case PartyMode.hangover:
        return const Color(0xFF06B6D4); // สีฟ้า/เขียวมิ้นต์สดชื่น
    }
  }
}

/// หมวดหมู่สินค้าในตู้
enum ProductCategory {
  recovery, // กู้ร่าง & แก้แฮงค์
  fashion, // แฟชั่น & ร่างกายฉุกเฉิน
  freshness, // ดับกลิ่น & รีเฟรช
  tech, // อุปกรณ์เอาชีวิตรอด
}

extension ProductCategoryX on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.recovery:
        return S.categoryRecovery;
      case ProductCategory.fashion:
        return S.categoryFashion;
      case ProductCategory.freshness:
        return S.categoryFreshness;
      case ProductCategory.tech:
        return S.categoryTech;
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.recovery:
        return Icons.local_pharmacy_rounded;
      case ProductCategory.fashion:
        return Icons.checkroom_rounded;
      case ProductCategory.freshness:
        return Icons.water_drop_rounded;
      case ProductCategory.tech:
        return Icons.bolt_rounded;
    }
  }
}

class Product {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final ProductCategory category;

  /// จำนวนสต็อกตั้งต้นของสินค้าชิ้นนี้ในตู้ (ใช้เริ่มระบบตัดสต็อกเรียลไทม์
  /// ดูตัวจัดการจริงที่ lib/data/stock_manager.dart)
  final int initialStock;

  const Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
    this.initialStock = 10,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;
}