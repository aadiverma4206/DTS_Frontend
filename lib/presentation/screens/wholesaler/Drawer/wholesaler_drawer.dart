import 'package:drug_tracking_system/presentation/screens/auth/detail_registration_form/manufacturer_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/login/login_screen.dart';
import '../../auth/login/logout_system.dart';
import '../pages/stock/stock_history_screen.dart';
import '../pages/stock/stock_screen.dart';
import '../pages/stock/supply_stock.dart';

class _D {
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const teal = Color(0xFF0D9488);
  static const tealSoft = Color(0xFFCCFBF1);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const violet = Color(0xFF7C3AED);
  static const violetSoft = Color(0xFFEDE9FE);
}

class WholesalerDrawer extends StatelessWidget {
  const WholesalerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Drawer(
      width: w < 400 ? w * 0.82 : 300,
      backgroundColor: _D.surface,
      child: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerTile(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Add Manufacturer',
                    iconColor: _D.violet,
                    iconBg: _D.violetSoft,
                    onTap: () {
                      Get.back();
                      Get.to(() => const ManufacturerForm());
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.inventory_2_rounded,
                    label: 'My Stock',
                    iconColor: _D.teal,
                    iconBg: _D.tealSoft,
                    onTap: () {
                      Get.back();
                      Get.to(() => const StockScreen());
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.add_box_rounded,
                    label: 'Create Invoice',
                    iconColor: _D.blue,
                    iconBg: _D.blueSoft,
                    onTap: () {
                      Get.back();
                      Get.to(() => const SupplyStockScreen());
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: 'Stock History',
                    iconColor: _D.amber,
                    iconBg: _D.amberSoft,
                    onTap: () {
                      Get.back();
                      Get.to(() => const StockHistoryScreen());
                    },
                  ),
                  const SizedBox(height: 12),
                  Divider(color: _D.divider, thickness: 1),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _DrawerTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                iconColor: _D.rose,
                iconBg: _D.roseSoft,
                onTap: () => LogoutSystem.logout(showConfirm: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Wholesaler Panel',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Drug Tracking System',
            style: GoogleFonts.nunito(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: _D.indigoSoft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _D.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: _D.textSub, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
