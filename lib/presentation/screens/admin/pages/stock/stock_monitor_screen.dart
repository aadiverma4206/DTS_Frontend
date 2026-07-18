import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'stock_display.dart';

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
  static const slate = Color(0xFF475569);
  static const slateSoft = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    this.width = double.infinity,
    this.height = 16,
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
      duration: const Duration(milliseconds: 1000),
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
          gradient: LinearGradient(
            colors: [
              Color.lerp(_C.divider, const Color(0xFFCBD5E1), _anim.value)!,
              Color.lerp(const Color(0xFFCBD5E1), _C.divider, _anim.value)!,
            ],
          ),
        ),
      ),
    );
  }
}

class StockMonitorScreen extends StatefulWidget {
  const StockMonitorScreen({super.key});

  @override
  State<StockMonitorScreen> createState() => _StockMonitorScreenState();
}

class _StockMonitorScreenState extends State<StockMonitorScreen>
    with SingleTickerProviderStateMixin {
  bool _isOverviewLoading = true;
  bool _isListLoading = true;
  bool _isOverviewReloading = false;

  List<Map<String, dynamic>> _users = [];

  String _selectedRole = 'all';
  String _searchQuery = '';
  String? _overviewError;
  String? _listError;

  int _totalCount = 0;
  int _wholesalerCount = 0;
  int _retailerCount = 0;

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadOverview();
    _loadList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _searchQuery = val.trim());
      _loadList();
    });
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() {
      _isOverviewLoading = true;
      _overviewError = null;
    });
    try {
      final data = await AdminApi.getStockUsers(role: 'all', search: '');
      if (!mounted) return;
      _computeOverview(data);
      setState(() => _isOverviewLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOverviewLoading = false;
        _overviewError = e.toString();
      });
    }
  }

  Future<void> _reloadOverview() async {
    if (!mounted || _isOverviewReloading) return;
    setState(() {
      _isOverviewReloading = true;
      _overviewError = null;
    });
    try {
      final data = await AdminApi.getStockUsers(role: 'all', search: '');
      if (!mounted) return;
      _computeOverview(data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _overviewError = e.toString());
    }
    if (!mounted) return;
    setState(() => _isOverviewReloading = false);
  }

  Future<void> _loadList() async {
    if (!mounted) return;
    setState(() {
      _isListLoading = true;
      _listError = null;
    });
    try {
      final data = await AdminApi.getStockUsers(
        role: _selectedRole,
        search: _searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _users = data;
        _isListLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isListLoading = false;
        _listError = e.toString();
      });
    }
  }

  void _computeOverview(List<Map<String, dynamic>> data) {
    int w = 0, r = 0;
    for (final item in data) {
      final role = (item['role_name'] ?? '').toString().toLowerCase();
      if (role == 'wholesaler')
        w++;
      else if (role == 'retailer')
        r++;
    }
    setState(() {
      _totalCount = data.length;
      _wholesalerCount = w;
      _retailerCount = r;
    });
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16;
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _C.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _C.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSkeletonCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
      ),
      child: const Column(
        children: [
          _ShimmerBox(width: 30, height: 30, radius: 8),
          SizedBox(height: 6),
          _ShimmerBox(width: 32, height: 16),
          SizedBox(height: 4),
          _ShimmerBox(width: 48, height: 10),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                'Overview',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isOverviewReloading ? null : _reloadOverview,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.indigoSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.indigo.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isOverviewReloading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            color: _C.indigo,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: _C.indigo,
                        ),
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_overviewError != null && !_isOverviewLoading)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.roseSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.rose.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: _C.rose,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Overview could not load. Tap Reload.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.rose,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: _isOverviewLoading
                  ? List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                          child: _overviewSkeletonCard(),
                        ),
                      ),
                    )
                  : [
                      Expanded(
                        child: _overviewCard(
                          'Total',
                          '$_totalCount',
                          Icons.people_rounded,
                          _C.indigo,
                          _C.indigoSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Wholesalers',
                          '$_wholesalerCount',
                          Icons.warehouse_rounded,
                          _C.blue,
                          _C.blueSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Retailers',
                          '$_retailerCount',
                          Icons.store_rounded,
                          _C.green,
                          _C.greenSoft,
                        ),
                      ),
                    ],
            ),
        ],
      ),
    );
  }

  Widget _typeFilterRow() {
    final hp = _hPad;
    final opts = [
      {
        'key': 'all',
        'label': 'All',
        'icon': Icons.apps_rounded,
        'color': _C.indigo,
      },
      {
        'key': 'retailer',
        'label': 'Retailer',
        'icon': Icons.store_rounded,
        'color': _C.green,
      },
      {
        'key': 'wholesaler',
        'label': 'Wholesaler',
        'icon': Icons.warehouse_rounded,
        'color': _C.blue,
      },
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Type'),
          Row(
            children: List.generate(opts.length, (i) {
              final opt = opts[i];
              final sel = _selectedRole == opt['key'];
              final color = opt['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_selectedRole == opt['key']) return;
                    setState(() => _selectedRole = opt['key'] as String);
                    _loadList();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < opts.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: sel ? color : _C.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sel ? color : _C.divider),
                      boxShadow: [
                        BoxShadow(
                          color: sel
                              ? color.withValues(alpha: 0.18)
                              : _C.shadow,
                          blurRadius: sel ? 10 : 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          opt['icon'] as IconData,
                          size: 15,
                          color: sel ? Colors.white : color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          opt['label'] as String,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : _C.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Search'),
          Container(
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.divider),
              boxShadow: [
                BoxShadow(
                  color: _C.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or license...',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 13,
                  color: _C.textSub,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _C.indigo,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                          _loadList();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: _C.textSub,
                          size: 18,
                        ),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerUserCard() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const _ShimmerBox(width: 52, height: 52, radius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerBox(width: 140, height: 14),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 110, height: 11),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 90, height: 22, radius: 30),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const _ShimmerBox(width: 30, height: 30, radius: 15),
          ],
        ),
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> item) {
    final hp = _hPad;
    final userId = item['user_id'] ?? 0;
    final userName = item['name']?.toString() ?? '';
    final role = (item['role_name'] ?? '').toString().toLowerCase();
    final companyName = item['company_name']?.toString() ?? '';
    final shopName = item['shop_name']?.toString() ?? '';
    final license = item['wholesaler_license']?.toString().isNotEmpty == true
        ? item['wholesaler_license'].toString()
        : item['retailer_license']?.toString() ?? '';
    final displayName = role == 'wholesaler' ? companyName : shopName;
    final isWholesaler = role == 'wholesaler';
    final roleColor = isWholesaler ? _C.blue : _C.green;
    final roleBg = isWholesaler ? _C.blueSoft : _C.greenSoft;
    final roleIcon = isWholesaler
        ? Icons.warehouse_rounded
        : Icons.store_rounded;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 10),
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDisplayScreen(
                userId: userId,
                userName: userName,
                shopName: displayName,
                userType: role,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.divider),
              boxShadow: [
                BoxShadow(
                  color: _C.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: roleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (displayName.isNotEmpty)
                        Row(
                          children: [
                            Icon(roleIcon, size: 11, color: _C.textSub),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: _C.textSub,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: roleBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isWholesaler ? 'Wholesaler' : 'Retailer',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: roleColor,
                              ),
                            ),
                          ),
                          if (license.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.indigoSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  license,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _C.indigo,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _C.indigoSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: _C.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listErrorWidget() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.roseSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.rose.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: _C.rose, size: 36),
            const SizedBox(height: 12),
            Text(
              'Failed to load users',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _C.rose,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _listError ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: _C.rose,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadList,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _C.rose,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Try Again',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 20, hp, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters or search',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: _C.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          'Stock Monitor',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            color: _C.indigo,
            onRefresh: () async {
              await Future.wait([_loadOverview(), _loadList()]);
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _overviewSection(),
                      const SizedBox(height: 18),
                      _typeFilterRow(),
                      const SizedBox(height: 14),
                      _searchField(),
                      const SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
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
                              'Users',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!_isListLoading)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.indigoSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_users.length}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _C.indigo,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                if (_isListLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _shimmerUserCard(),
                      childCount: 6,
                    ),
                  )
                else if (_listError != null)
                  SliverToBoxAdapter(child: _listErrorWidget())
                else if (_users.isEmpty)
                  SliverToBoxAdapter(child: _emptyWidget())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => FadeTransition(
                        opacity: _fadeAnim,
                        child: _userCard(_users[i]),
                      ),
                      childCount: _users.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
