import 'package:flutter/material.dart';
import '../models/product.dart';
import 'shop_screen.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  void _goToShop(BuildContext context, PartyMode? mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopScreen(initialMode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF120E1F), Color(0xFF1E1533), Color(0xFF120E1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text('🪩', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text(
                  'ตู้ปาร์ตี้',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Night Out & Hangover Rescue',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'สภาพยังไงตอนนี้? เลือกโหมดให้เราช่วยแนะนำ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                _ModeCard(
                  mode: PartyMode.preParty,
                  onTap: () => _goToShop(context, PartyMode.preParty),
                ),
                const SizedBox(height: 18),
                _ModeCard(
                  mode: PartyMode.hangover,
                  onTap: () => _goToShop(context, PartyMode.hangover),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _goToShop(context, null),
                  child: const Text(
                    'ดูสินค้าทั้งหมด ไม่เลือกโหมด →',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final PartyMode mode;
  final VoidCallback onTap;

  const _ModeCard({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              mode.color.withOpacity(0.85),
              mode.color.withOpacity(0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: mode.color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}