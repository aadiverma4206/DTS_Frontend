import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'package:drug_tracking_system/core/services/api_service/inspection_api.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const slate = Color(0xFF475569);
  static const slateSoft = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF8FAFC);
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
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
      duration: const Duration(milliseconds: 1100),
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
          color: Color.lerp(_C.shimmerBase, _C.shimmerHighlight, _anim.value),
        ),
      ),
    );
  }
}

class _ShimmerStatCard extends StatelessWidget {
  const _ShimmerStatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const _ShimmerBox(width: 44, height: 44, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ShimmerBox(width: 120, height: 13, radius: 6),
                SizedBox(height: 8),
                _ShimmerBox(width: 70, height: 10, radius: 5),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _ShimmerBox(width: 44, height: 32, radius: 10),
        ],
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  bool _overviewLoading = true;
  bool _overviewReloading = false;
  bool _stockLoading = true;

  int? _totalUsers;
  int? _totalInspections;
  int? _totalStock;
  int? _lowStock;

  String? _overviewError;
  String? _stockError;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadOverview();
    _loadStock();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOverview({bool reload = false}) async {
    if (!mounted) return;
    if (reload) {
      setState(() {
        _overviewReloading = true;
        _overviewError = null;
      });
    } else {
      setState(() {
        _overviewLoading = true;
        _overviewError = null;
      });
    }
    try {
      final users = await AdminApi.getAllUsers();
      final inspections = await InspectionApi.getAllInspections();
      if (!mounted) return;
      setState(() {
        _totalUsers = users.length;
        _totalInspections = inspections.length;
        _overviewLoading = false;
        _overviewReloading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _overviewError = e.toString().replaceAll('Exception:', '').trim();
        _overviewLoading = false;
        _overviewReloading = false;
      });
    }
  }

  Future<void> _loadStock() async {
    if (!mounted) return;
    setState(() {
      _stockLoading = true;
      _stockError = null;
    });
    try {
      final stock = await AdminApi.getStockMonitor();
      if (!mounted) return;
      setState(() {
        _totalStock = stock.length;
        _lowStock = stock.where((e) => (e['quantity'] ?? 0) < 10).length;
        _stockLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stockError = e.toString().replaceAll('Exception:', '').trim();
        _stockLoading = false;
      });
    }
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16;
  }

  Widget _sectionLabel(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _C.indigo,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String subtitle,
    required int value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.divider),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _C.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$value',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.roseSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.rose.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.rose.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.error_rounded, color: _C.rose, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.isNotEmpty ? message : 'Failed to load data',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.rose,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _C.rose,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reloadButton({required bool loading, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _C.indigoSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.indigo.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: _C.indigo,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.refresh_rounded, size: 14, color: _C.indigo),
            const SizedBox(width: 5),
            Text(
              'Reload',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _C.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.indigoSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.indigo.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.indigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: _C.indigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Admin insights help monitor system health and detect issues early.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.indigo,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          'System Overview',
          trailing: _reloadButton(
            loading: _overviewReloading,
            onTap: () => _loadOverview(reload: true),
          ),
        ),
        if (_overviewLoading) ...[
          const _ShimmerStatCard(),
          const _ShimmerStatCard(),
        ] else if (_overviewError != null) ...[
          _errorCard(_overviewError!, () => _loadOverview(reload: true)),
        ] else ...[
          _statCard(
            title: 'Total Users',
            subtitle: 'Registered in system',
            value: _totalUsers ?? 0,
            icon: Icons.people_rounded,
            color: _C.purple,
            bg: _C.purpleSoft,
          ),
          _statCard(
            title: 'Total Inspections',
            subtitle: 'All time inspections',
            value: _totalInspections ?? 0,
            icon: Icons.verified_rounded,
            color: _C.green,
            bg: _C.greenSoft,
          ),
        ],
      ],
    );
  }

  Widget _stockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Stock Analytics'),
        if (_stockLoading) ...[
          const _ShimmerStatCard(),
          const _ShimmerStatCard(),
        ] else if (_stockError != null) ...[
          _errorCard(_stockError!, _loadStock),
        ] else ...[
          _statCard(
            title: 'Total Stock Items',
            subtitle: 'Items in inventory',
            value: _totalStock ?? 0,
            icon: Icons.inventory_2_rounded,
            color: _C.blue,
            bg: _C.blueSoft,
          ),
          _statCard(
            title: 'Low Stock Alerts',
            subtitle: 'Quantity below 10',
            value: _lowStock ?? 0,
            icon: Icons.warning_amber_rounded,
            color: _C.rose,
            bg: _C.roseSoft,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = _hPad;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Reports',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(color: _C.bg),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _C.indigo,
          onRefresh: () async {
            await Future.wait([_loadOverview(reload: true), _loadStock()]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(hp, 6, hp, 30),
            children: [
              _overviewSection(),
              const SizedBox(height: 22),
              _stockSection(),
              const SizedBox(height: 22),
              _insightsBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
