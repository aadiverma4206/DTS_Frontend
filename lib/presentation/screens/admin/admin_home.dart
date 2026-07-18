import 'package:carousel_slider/carousel_slider.dart';
import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'package:drug_tracking_system/core/services/api_service/inspection_api.dart';
import 'package:drug_tracking_system/presentation/screens/admin/pages/AddDrugs/add_drug_screen.dart';
import 'package:drug_tracking_system/presentation/screens/inspector/pages/Info/retailer_info.dart';
import 'package:drug_tracking_system/presentation/screens/inspector/pages/Info/wholesaler_info.dart';
import 'package:drug_tracking_system/presentation/screens/admin/pages/Inspections/inspection_list_screen.dart';
import 'package:drug_tracking_system/presentation/screens/inspector/pages/drugs/drug_list_screen.dart';
import 'package:drug_tracking_system/presentation/screens/inspector/pages/sales/sale_list.dart';
import 'package:drug_tracking_system/presentation/screens/inspector/pages/stock/stock_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Drawer/admin_drawer.dart';
import 'pages/inspector/create_inspector_screen.dart';
import 'pages/stock/stock_monitor_screen.dart';
import 'pages/users/user_list_screen.dart';
import 'reports_screen.dart';

class _A {
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
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF5F3FF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF8FAFC);
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _idx = 0;

  final List<Widget> _pages = const [
    UserListScreen(),
    InspectionListScreen(),
    StockMonitorScreen(),
    ReportsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 900;

    return Scaffold(
      backgroundColor: _A.bg,
      appBar: _idx == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.deepPurple,
              centerTitle: true,
              title: Text(
                "Admin Dashboard",
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Container(height: 24, color: _A.bg),
              ),
            )
          : null,
      drawer: isDesktop ? null : const AdminDrawer(),
      body: isDesktop
          ? Row(
              children: [
                _DesktopSidebar(
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                Expanded(
                  child: _idx == 0
                      ? _AdminDashboardBody(
                          onNavigate: (i) => setState(() => _idx = i),
                        )
                      : IndexedStack(index: _idx - 1, children: _pages),
                ),
              ],
            )
          : _idx == 0
          ? _AdminDashboardBody(onNavigate: (i) => setState(() => _idx = i))
          : _pages[_idx - 1],
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _A.surface,
        boxShadow: [
          BoxShadow(
            color: _A.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(
                1,
                Icons.people_rounded,
                Icons.people_outline_rounded,
                'Users',
              ),
              _navItem(
                2,
                Icons.assignment_rounded,
                Icons.assignment_outlined,
                'Inspect',
              ),
              _navItem(
                3,
                Icons.inventory_rounded,
                Icons.inventory_2_outlined,
                'Stock',
              ),
              _navItem(
                4,
                Icons.bar_chart_rounded,
                Icons.bar_chart_outlined,
                'Reports',
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _A.indigoSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sel ? active : inactive,
              color: sel ? _A.indigo : _A.textSub,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                color: sel ? _A.indigo : _A.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_rounded, 'Dashboard'),
      (Icons.people_rounded, 'Users'),
      (Icons.assignment_rounded, 'Inspections'),
      (Icons.inventory_2_rounded, 'Stock Monitor'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.person_add_rounded, 'Create Inspector'),
    ];

    return Container(
      width: 240,
      color: _A.surface,
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.deepPurple,
            child: Text(
              'Admin Panel',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(items.length, (i) {
                final sel = currentIndex == i;
                return ListTile(
                  leading: Icon(
                    items[i].$1,
                    color: sel ? _A.indigo : _A.textSub,
                  ),
                  title: Text(
                    items[i].$2,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: sel ? _A.indigo : _A.textPrimary,
                    ),
                  ),
                  tileColor: sel ? _A.indigoSoft : Colors.transparent,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ],
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
          color: Color.lerp(_A.shimmerBase, _A.shimmerHighlight, _anim.value),
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
          color: _A.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _A.divider),
          boxShadow: [
            BoxShadow(
              color: _A.shadow,
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

class _AdminDashboardBody extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const _AdminDashboardBody({this.onNavigate});

  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody>
    with SingleTickerProviderStateMixin {
  int _slide = 0;
  bool _statsLoading = true;
  bool _statsError = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _carouselCtrl = CarouselSliderController();

  int totalUsers = 0;
  int totalInspections = 0;
  int totalStockItems = 0;
  int issueCount = 0;

  final _banners = [
    'assets/slider_images/banner1.png',
    'assets/slider_images/banner2.png',
    'assets/slider_images/banner3.png',
  ];

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
      final users = await AdminApi.getAllUsers();
      final inspections = await InspectionApi.getAllInspections();
      final stock = await AdminApi.getStockMonitor();
      final issues = inspections
          .where((i) => i['status'] == 'discrepancy')
          .length;

      if (!mounted) return;
      setState(() {
        totalUsers = users.length;
        totalInspections = inspections.length;
        totalStockItems = stock.length;
        issueCount = issues;
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
        backgroundColor: _A.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.05;
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
              color: _A.indigo,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _A.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          if (onReload != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: reloading ? null : onReload,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: reloading
                      ? _A.indigoSoft.withOpacity(0.5)
                      : _A.indigoSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _A.indigo.withOpacity(0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reloading
                        ? SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _A.indigo,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: _A.indigo,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      reloading ? 'Loading...' : 'Reload',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _A.indigo,
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
          color: _A.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _A.divider),
          boxShadow: [
            BoxShadow(
              color: _A.shadow,
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
                    color: _A.textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: mobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: _A.textSub,
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
      return Column(
        children: [
          Row(children: const [_StatsSkeletonCard(), _StatsSkeletonCard()]),
          Row(children: const [_StatsSkeletonCard(), _StatsSkeletonCard()]),
        ],
      );
    }

    if (_statsError) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: _A.roseSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _A.rose.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: _A.rose, size: 20),
            const SizedBox(width: 10),
            Text(
              'Could not load stats',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _A.rose,
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
                title: 'Users',
                value: '$totalUsers',
                icon: Icons.people_rounded,
                color: _A.indigo,
                bg: _A.indigoSoft,
              ),
              _statsCard(
                title: 'Inspections',
                value: '$totalInspections',
                icon: Icons.verified_rounded,
                color: _A.green,
                bg: _A.greenSoft,
              ),
            ],
          ),
          Row(
            children: [
              _statsCard(
                title: 'Stock',
                value: '$totalStockItems',
                icon: Icons.inventory_2_rounded,
                color: _A.amber,
                bg: _A.amberSoft,
              ),
              _statsCard(
                title: 'Issues',
                value: '$issueCount',
                icon: Icons.warning_amber_rounded,
                color: _A.rose,
                bg: _A.roseSoft,
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
            color: _A.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _A.divider),
            boxShadow: [
              BoxShadow(
                color: _A.shadow,
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
                  color: _A.textPrimary,
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
    return RefreshIndicator(
      color: _A.indigo,
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
                  title: 'Inspection',
                  icon: Icons.verified_user_rounded,
                  color: _A.indigo,
                  bg: _A.indigoSoft,
                  onTap: () => Get.to(() => InspectionListScreen()),
                ),
                _actionBtn(
                  title: 'Stock',
                  icon: Icons.inventory_2_rounded,
                  color: _A.green,
                  bg: _A.greenSoft,
                  onTap: () => Get.to(() => StockListScreen()),
                ),
              ],
            ),
            Row(
              children: [
                _actionBtn(
                  title: 'Drugs',
                  icon: Icons.medication_rounded,
                  color: _A.teal,
                  bg: _A.tealSoft,
                  onTap: () => Get.to(() => DrugListScreen()),
                ),

                _actionBtn(
                  title: 'Sale',
                  icon: Icons.sell_rounded,
                  color: _A.rose,
                  bg: _A.roseSoft,
                  onTap: () => Get.to(() => SaleListScreen()),
                ),
              ],
            ),
            Row(
              children: [
                _actionBtn(
                  title: 'Wholesalers',
                  icon: Icons.group_rounded,
                  color: _A.blue,
                  bg: _A.blueSoft,
                  onTap: () => Get.to(() => WholesalerInfoScreen()),
                ),
                _actionBtn(
                  title: 'Retailer',
                  icon: Icons.store_rounded,
                  color: _A.amber,
                  bg: _A.amberSoft,
                  onTap: () => Get.to(() => RetailerInfoScreen()),
                ),
              ],
            ),
            Row(
              children: [
                _actionBtn(
                  title: 'Add Inspector',
                  icon: Icons.person_add_outlined,
                  color: _A.purple,
                  bg: _A.purpleSoft,
                  onTap: () => Get.to(() => CreateInspectorScreen()),
                ),
                _actionBtn(
                  title: 'Add Drugs',
                  icon: Icons.medical_services_outlined,
                  color: _A.textSub,
                  bg: _A.bg,
                  onTap: () => Get.to(() => AddDrugScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
