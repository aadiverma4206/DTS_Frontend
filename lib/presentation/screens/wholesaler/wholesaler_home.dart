import 'package:carousel_slider/carousel_slider.dart';
import 'package:drug_tracking_system/core/services/api_service/wholesaler_api.dart';
import 'package:drug_tracking_system/presentation/screens/auth/detail_registration_form/manufacturer_form.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/Drawer/wholesaler_drawer.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/Profile/wholesaler_profile.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/Invoice_retailer/invoice_list_screen.dart';
import 'package:drug_tracking_system/presentation/screens/admin/pages/AddDrugs/add_drug_screen.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/New_drug_Batch/create_batch_screen.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/Suppliers/manufacturer_list.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/stock/received_stock.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/Suppliers/retailer_list.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/stock/reject_stock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/stock/stock_history_screen.dart';
import 'pages/stock/stock_screen.dart';
import 'pages/stock/supply_stock.dart';
class _W {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoLight = Color(0xFF6366F1);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const teal = Color(0xFF0D9488);
  static const tealSoft = Color(0xFFCCFBF1);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF8FAFC);
}

class WholesalerHome extends StatefulWidget {
  const WholesalerHome({super.key});

  @override
  State<WholesalerHome> createState() => _WholesalerHomeState();
}

class _WholesalerHomeState extends State<WholesalerHome> {
  int _idx = 0;

  final _pages = [
    const WholesalerDashboard(),
    const StockScreen(),
    const SupplyStockScreen(),
    const StockHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _W.surface,
        boxShadow: [
          BoxShadow(
            color: _W.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(
                1,
                Icons.inventory_2_rounded,
                Icons.inventory_2_outlined,
                'Stock',
              ),
              _navItem(
                2,
                Icons.local_shipping_rounded,
                Icons.local_shipping_outlined,
                'Supply',
              ),
              _navItem(3, Icons.history_rounded, Icons.history, 'History'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData active, IconData inactive, String label) {
    final sel = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _W.indigoSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sel ? active : inactive,
              color: sel ? _W.indigo : _W.textSub,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                color: sel ? _W.indigo : _W.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(_W.shimmerBase, _W.shimmerHighlight, _anim.value),
        ),
      ),
    );
  }
}

class _StatsSkeletonCard extends StatelessWidget {
  const _StatsSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        height: mobile ? 125 : 140,
        margin: const EdgeInsets.all(5),
        padding: EdgeInsets.all(mobile ? 14 : 16),
        decoration: BoxDecoration(
          color: _W.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _W.divider),
          boxShadow: [
            BoxShadow(
              color: _W.shadow,
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _ShimmerBox(width: 38, height: 38, radius: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: mobile ? 48 : 56,
                  height: mobile ? 22 : 26,
                  radius: 6,
                ),
                const SizedBox(height: 6),
                _ShimmerBox(width: mobile ? 60 : 72, height: 12, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WholesalerDashboard extends StatefulWidget {
  const WholesalerDashboard({super.key});

  @override
  State<WholesalerDashboard> createState() => _WholesalerDashboardState();
}

class _WholesalerDashboardState extends State<WholesalerDashboard>
    with SingleTickerProviderStateMixin {
  int _slide = 0;
  bool _statsLoading = true;
  bool _statsError = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _carouselCtrl = CarouselSliderController();

  final _banners = [
    'assets/slider_images/banner1.png',
    'assets/slider_images/banner2.png',
    'assets/slider_images/banner3.png',
  ];

  Map<String, dynamic> _data = {
    'total_stock': 0,
    'supplied': 0,
    'history': 0,
    'manufacturers': 0,
  };

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadStats();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _statsLoading = true;
      _statsError = false;
    });
    try {
      final res = await WholesalerApi.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _data = {
          'total_stock': res['total_stock'] ?? 0,
          'supplied': res['supplied'] ?? 0,
          'history': res['history'] ?? 0,
          'manufacturers': res['manufacturers'] ?? 0,
        };
        _statsLoading = false;
        _statsError = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statsLoading = false;
        _statsError = true;
      });
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _W.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.06;
    return 16;
  }

  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          CarouselSlider(
            carouselController: _carouselCtrl,
            items: _banners
                .map(
                  (p) =>
                      Image.asset(p, fit: BoxFit.cover, width: double.infinity),
                )
                .toList(),
            options: CarouselOptions(
              height: 185,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 650),
              onPageChanged: (i, _) => setState(() => _slide = i),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _slide == i ? 20 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _slide == i ? Colors.white : Colors.white54,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(
    String text, {
    VoidCallback? onReload,
    bool reloading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _W.indigo,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _W.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          if (onReload != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: reloading ? null : onReload,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: reloading
                      ? _W.indigoSoft.withOpacity(0.5)
                      : _W.indigoSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _W.indigo.withOpacity(0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reloading
                        ? const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _W.indigo,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: _W.indigo,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      reloading ? 'Loading...' : 'Reload',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _W.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    final mobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        height: mobile ? 125 : 140,
        margin: const EdgeInsets.all(5),
        padding: EdgeInsets.all(mobile ? 14 : 16),
        decoration: BoxDecoration(
          color: _W.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _W.divider),
          boxShadow: [
            BoxShadow(
              color: _W.shadow,
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: mobile ? 18 : 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: mobile ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    color: _W.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: mobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: _W.textSub,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_statsLoading) {
      return const Column(
        children: [
          Row(children: [_StatsSkeletonCard(), _StatsSkeletonCard()]),
          Row(children: [_StatsSkeletonCard(), _StatsSkeletonCard()]),
        ],
      );
    }

    if (_statsError) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: _W.roseSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _W.rose.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _W.rose, size: 20),
            const SizedBox(width: 10),
            Text(
              'Could not load stats',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _W.rose,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          Row(
            children: [
              _statsCard(
                title: 'Total Stock',
                value: '${_data["total_stock"]}',
                icon: Icons.inventory_2_rounded,
                color: _W.indigo,
                bg: _W.indigoSoft,
              ),
              _statsCard(
                title: 'Supplied',
                value: '${_data["supplied"]}',
                icon: Icons.local_shipping_rounded,
                color: _W.teal,
                bg: _W.tealSoft,
              ),
            ],
          ),
          Row(
            children: [
              _statsCard(
                title: 'History',
                value: '${_data["history"]}',
                icon: Icons.history_rounded,
                color: _W.amber,
                bg: _W.amberSoft,
              ),
              _statsCard(
                title: 'Manufacturers',
                value: '${_data["manufacturers"]}',
                icon: Icons.factory_rounded,
                color: _W.green,
                bg: _W.greenSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String title,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    final mobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(
            vertical: mobile ? 14 : 18,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: _W.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _W.divider),
            boxShadow: [
              BoxShadow(
                color: _W.shadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: mobile ? 22 : 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: mobile ? 11 : 13,
                  color: _W.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Wholesaler Dashboard',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(
              color: _W.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      drawer: const WholesalerDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: _W.indigo,
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(_hPad, 10, _hPad, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _banner(),
                const SizedBox(height: 24),
                _sectionLabel(
                  'Overview',
                  onReload: _loadStats,
                  reloading: _statsLoading,
                ),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _sectionLabel('Quick Actions'),
                Row(
                  children: [
                    _actionBtn(
                      title: 'Received Stock',
                      icon: Icons.inventory_rounded,
                      color: _W.blue,
                      bg: _W.blueSoft,
                      onTap: () => Get.to(() => const ReceivedStock()),
                    ),
                    _actionBtn(
                      title: 'Receive Stock',
                      icon: Icons.add_box_rounded,
                      color: _W.teal,
                      bg: _W.tealSoft,
                      onTap: () => Get.to(() => const CreateBatchScreen()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _actionBtn(
                      title: 'Invoice List',
                      icon: Icons.receipt_long_rounded,
                      color: _W.blue,
                      bg: _W.blueSoft,
                      onTap: () => Get.to(() => const InvoiceListScreen()),
                    ),
                    _actionBtn(
                      title: 'View History',
                      icon: Icons.history_toggle_off_rounded,
                      color: _W.amber,
                      bg: _W.amberSoft,
                      onTap: () => Get.to(() => const StockHistoryScreen()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _actionBtn(
                      title: 'Add Manufacturer',
                      icon: Icons.group_add_rounded,
                      color: _W.green,
                      bg: _W.greenSoft,
                      onTap: () => Get.to(() => const ManufacturerForm()),
                    ),
                    _actionBtn(
                      title: 'Rejected Stock',
                      icon: Icons.cancel_outlined,
                      color: _W.rose,
                      bg: _W.roseSoft,
                      onTap: () => Get.to(() => const RejectStock()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _actionBtn(
                      title: 'Manufacturers',
                      icon: Icons.factory_outlined,
                      color: _W.indigo,
                      bg: _W.indigoSoft,
                      onTap: () => Get.to(() => const ManufacturerList()),
                    ),
                    _actionBtn(
                      title: 'Retailers',
                      icon: Icons.store_rounded,
                      color: _W.teal,
                      bg: _W.tealSoft,
                      onTap: () => Get.to(() => const RetailerList()),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _actionBtn(
                      title: 'Profile',
                      icon: Icons.person_2_outlined,
                      color: _W.indigo,
                      bg: _W.indigoSoft,
                      onTap: () => Get.to(() => const WholesalerProfile()),
                    ),
                    _actionBtn(
                      title: 'Help',
                      icon: Icons.help_outline_rounded,
                      color: _W.amber,
                      bg: _W.amberSoft,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
