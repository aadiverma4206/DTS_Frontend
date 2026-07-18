import 'package:carousel_slider/carousel_slider.dart';
import 'package:drug_tracking_system/core/services/api_service/retailer_api.dart';
import 'package:drug_tracking_system/presentation/screens/retailer/pages/Suppliers/manufacturers/manufacturer_list.dart';
import 'package:drug_tracking_system/presentation/screens/retailer/pages/Suppliers/patients/patient_list.dart';
import 'package:drug_tracking_system/presentation/screens/retailer/pages/Suppliers/wholesalers/wholesaler_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Drawer/retailer_drawer.dart';
import 'pages/Invoice/purchase_screen.dart';
import 'pages/sales/sale_history_screen.dart';
import 'pages/sales/sale_screen.dart';
import 'pages/stock/stock_screen.dart';

class RetailerHome extends StatefulWidget {
  const RetailerHome({super.key});

  @override
  State<RetailerHome> createState() => _RetailerHomeState();
}

class _RetailerHomeState extends State<RetailerHome> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    RetailerDashboard(),
    PurchaseScreen(),
    StockScreen(),
    SaleScreen(),
    SaleHistoryScreen(),
  ];

  final List<String> titles = [
    "Retailer Dashboard",
    "Purchase",
    "Stock",
    "Sell",
    "History",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FB),
      appBar: currentIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.deepPurple,
              centerTitle: true,
              title: Text(
                titles[currentIndex],
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  height: 28,
                  decoration: const BoxDecoration(color: Colors.white),
                ),
              ),
            )
          : null,
      drawer: const RetailerDrawer(),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x14602EE8),
              blurRadius: 16,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          selectedItemColor: const Color(0xFF8640F6),
          unselectedItemColor: const Color(0xFF7B7494),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: "Purchase",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: "Stock",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_rounded),
              label: "Sell",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
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
          color: Color.lerp(
            const Color(0xFFE5E0F5),
            const Color(0xFFF8F6FF),
            _anim.value,
          ),
        ),
      ),
    );
  }
}

class _StatsSkeletonCard extends StatelessWidget {
  const _StatsSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        height: isMobile ? 120 : 132,
        margin: const EdgeInsets.all(5),
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E0F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14602EE8),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _ShimmerBox(width: 40, height: 40, radius: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: isMobile ? 48 : 56,
                  height: isMobile ? 22 : 26,
                  radius: 6,
                ),
                const SizedBox(height: 6),
                _ShimmerBox(width: isMobile ? 60 : 72, height: 12, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RetailerDashboard extends StatefulWidget {
  const RetailerDashboard({super.key});

  @override
  State<RetailerDashboard> createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF8640F6);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);
  static const Color _acceptColor = Color(0xFF00B87A);
  static const Color _acceptBg = Color(0xFFE6F9F2);
  static const Color _pendingColor = Color(0xFFF59E0B);
  static const Color _pendingBg = Color(0xFFFFF8EC);

  int currentSlider = 0;
  bool _statsLoading = true;
  bool _statsError = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final CarouselSliderController carouselController =
      CarouselSliderController();

  final List<Map<String, dynamic>> imageList = [
    {"image_path": "assets/slider_images/banner1.png"},
    {"image_path": "assets/slider_images/banner2.png"},
    {"image_path": "assets/slider_images/banner3.png"},
  ];

  Map<String, dynamic> dashboardData = {
    "stock": 0,
    "purchased": 0,
    "sales": 0,
    "history": 0,
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
      final response = await RetailerApi.getDashboard();
      if (!mounted) return;
      setState(() {
        dashboardData = {
          "stock": response["stock"] ?? 0,
          "purchased": response["purchased"] ?? 0,
          "sales": response["sales"] ?? 0,
          "history": response["history"] ?? 0,
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
        "Error",
        e.toString().replaceAll("Exception:", "").trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Widget _statsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        height: isMobile ? 120 : 132,
        margin: const EdgeInsets.all(5),
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _divider),
          boxShadow: const [
            BoxShadow(color: _cardShadow, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 18 : 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _textSecondary,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w500,
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
          color: const Color(0xFFFFEDED),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Text(
              'Could not load stats',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.red,
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
                title: "Stock",
                value: "${dashboardData["stock"] ?? 0}",
                icon: Icons.inventory_2_rounded,
                color: _purple,
                bgColor: _purpleSoft,
              ),
              _statsCard(
                title: "Purchased",
                value: "${dashboardData["purchased"] ?? 0}",
                icon: Icons.shopping_cart_rounded,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ],
          ),
          Row(
            children: [
              _statsCard(
                title: "Sales",
                value: "${dashboardData["sales"] ?? 0}",
                icon: Icons.point_of_sale_rounded,
                color: _pendingColor,
                bgColor: _pendingBg,
              ),
              _statsCard(
                title: "History",
                value: "${dashboardData["history"] ?? 0}",
                icon: Icons.history_rounded,
                color: _acceptColor,
                bgColor: _acceptBg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 14 : 18,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _divider),
            boxShadow: const [
              BoxShadow(
                color: _cardShadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: isMobile ? 22 : 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 11 : 13,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String label, {
    VoidCallback? onReload,
    bool reloading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _purpleSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: _purple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
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
                  color: reloading ? _purpleSoft.withOpacity(0.5) : _purpleSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withOpacity(0.18)),
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
                              color: _purple,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: _purple,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      reloading ? 'Loading...' : 'Reload',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final double horizontalPad = isDesktop
        ? width * 0.18
        : width > 600
        ? width * 0.08
        : 16;

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: _purple,
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: imageList.map((item) {
                        return Image.asset(
                          item["image_path"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      }).toList(),
                      carouselController: carouselController,
                      options: CarouselOptions(
                        height: 180,
                        viewportFraction: 1,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(
                          milliseconds: 700,
                        ),
                        onPageChanged: (index, reason) {
                          setState(() => currentSlider = index);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imageList.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: currentSlider == entry.key ? 18 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: currentSlider == entry.key
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(height: 1, color: _divider),
              const SizedBox(height: 14),
              _sectionHeader(
                "OVERVIEW",
                onReload: _loadStats,
                reloading: _statsLoading,
              ),
              _buildStatsSection(),
              const SizedBox(height: 20),
              Container(height: 1, color: _divider),
              const SizedBox(height: 14),
              _sectionHeader("QUICK ACTIONS"),
              Row(
                children: [
                  _actionButton(
                    title: "Purchase",
                    icon: Icons.shopping_cart_rounded,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    onTap: () => Get.to(() => const PurchaseScreen()),
                  ),
                  _actionButton(
                    title: "Sell",
                    icon: Icons.point_of_sale_rounded,
                    color: _pendingColor,
                    bgColor: _pendingBg,
                    onTap: () => Get.to(() => const SaleScreen()),
                  ),
                ],
              ),
              Row(
                children: [
                  _actionButton(
                    title: "Stock",
                    icon: Icons.inventory_2_rounded,
                    color: _purple,
                    bgColor: _purpleSoft,
                    onTap: () => Get.to(() => const StockScreen()),
                  ),
                  _actionButton(
                    title: "History",
                    icon: Icons.history_rounded,
                    color: _acceptColor,
                    bgColor: _acceptBg,
                    onTap: () => Get.to(() => const SaleHistoryScreen()),
                  ),
                ],
              ),
              Row(
                children: [
                  _actionButton(
                    title: "Manufacturers",
                    icon: Icons.business_rounded,
                    color: _purple,
                    bgColor: _purpleSoft,
                    onTap: () => Get.to(() => const ManufacturerList()),
                  ),
                  _actionButton(
                    title: "Wholesalers",
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    onTap: () => Get.to(() => const WholesalerList()),
                  ),
                ],
              ),
              Row(
                children: [
                  _actionButton(
                    title: "Patient Sales",
                    icon: Icons.medical_information_rounded,
                    color: _acceptColor,
                    bgColor: _acceptBg,
                    onTap: () => Get.to(() => const PatientList()),
                  ),
                  _actionButton(
                    title: "Help",
                    icon: Icons.help_outline_rounded,
                    color: _pendingColor,
                    bgColor: _pendingBg,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
