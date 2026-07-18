import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'stock_total_detail.dart';

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
      builder: (_, __) {
        return Container(
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
        );
      },
    );
  }
}

class StockDisplayScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String shopName;
  final String userType;

  const StockDisplayScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.shopName,
    this.userType = 'all',
  });

  @override
  State<StockDisplayScreen> createState() => _StockDisplayScreenState();
}

class _StockDisplayScreenState extends State<StockDisplayScreen>
    with SingleTickerProviderStateMixin {
  bool _isOverviewLoading = true;
  bool _isListLoading = true;
  bool _isOverviewReloading = false;

  List<Map<String, dynamic>> _allStock = [];

  String _searchQuery = '';
  String? _overviewError;
  String? _listError;

  int _totalCount = 0;
  int _lowCount = 0;
  int _okCount = 0;
  int _expiredCount = 0;

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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = val.trim());
    });
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() {
      _isOverviewLoading = true;
      _overviewError = null;
    });
    try {
      final data = await AdminApi.getUserStockList(widget.userId);
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
      final data = await AdminApi.getUserStockList(widget.userId);
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
      final data = await AdminApi.getUserStockList(widget.userId);
      if (!mounted) return;
      setState(() {
        _allStock = data;
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

  Future<void> _reloadList() async {
    if (!mounted) return;
    setState(() {
      _isListLoading = true;
      _listError = null;
    });
    try {
      final data = await AdminApi.getUserStockList(widget.userId);
      if (!mounted) return;
      setState(() {
        _allStock = data;
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
    final now = DateTime.now();
    int low = 0, ok = 0, exp = 0;
    for (final item in data) {
      final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      if (qty < 10)
        low++;
      else
        ok++;
      final expiryStr = item['expiry_date']?.toString() ?? '';
      if (expiryStr.isNotEmpty) {
        try {
          final expDate = DateTime.parse(expiryStr);
          if (expDate.isBefore(now)) exp++;
        } catch (_) {}
      }
    }
    setState(() {
      _totalCount = data.length;
      _lowCount = low;
      _okCount = ok;
      _expiredCount = exp;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _allStock.where((item) {
      final drug = (item['drug_name'] ?? '').toString().toLowerCase();
      final batch = (item['batch_no'] ?? '').toString().toLowerCase();
      final matchSearch = q.isEmpty || drug.contains(q) || batch.contains(q);
      return matchSearch;
    }).toList();
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
      child: Column(
        children: [
          const _ShimmerBox(width: 30, height: 30, radius: 8),
          const SizedBox(height: 6),
          const _ShimmerBox(width: 32, height: 16),
          const SizedBox(height: 4),
          const _ShimmerBox(width: 48, height: 10),
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
                      4,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                          child: _overviewSkeletonCard(),
                        ),
                      ),
                    )
                  : [
                      Expanded(
                        child: _overviewCard(
                          'Total',
                          '$_totalCount',
                          Icons.inventory_2_rounded,
                          _C.indigo,
                          _C.indigoSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'OK',
                          '$_okCount',
                          Icons.check_circle_rounded,
                          _C.green,
                          _C.greenSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Low',
                          '$_lowCount',
                          Icons.warning_amber_rounded,
                          _C.rose,
                          _C.roseSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Expired',
                          '$_expiredCount',
                          Icons.event_busy_rounded,
                          _C.amber,
                          _C.amberSoft,
                        ),
                      ),
                    ],
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
                hintText: 'Search drug name or batch...',
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

  Widget _headerCard() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _C.indigo.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.userType[0].toUpperCase() + widget.userType.substring(1),
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerStockCard() {
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
                  _ShimmerBox(width: 100, height: 11),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 120, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: const [
                _ShimmerBox(width: 36, height: 22),
                SizedBox(height: 6),
                _ShimmerBox(width: 28, height: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockCard(Map<String, dynamic> item) {
    final hp = _hPad;
    final stockId = item['stock_id'] ?? 0;
    final drug = item['drug_name']?.toString() ?? '';
    final batch = item['batch_no']?.toString() ?? '';
    final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    final expiry = item['expiry_date']?.toString() ?? '';
    final isLow = qty < 10;

    DateTime? expiryDate;
    bool isExpired = false;
    if (expiry.isNotEmpty) {
      try {
        expiryDate = DateTime.parse(expiry);
        isExpired = expiryDate.isBefore(DateTime.now());
      } catch (_) {}
    }

    final badgeColor = isExpired
        ? _C.amber
        : isLow
        ? _C.rose
        : _C.green;
    final badgeBg = isExpired
        ? _C.amberSoft
        : isLow
        ? _C.roseSoft
        : _C.greenSoft;
    final badgeLabel = isExpired
        ? 'EXPIRED'
        : isLow
        ? 'LOW'
        : 'OK';
    final badgeIcon = isExpired
        ? Icons.event_busy_rounded
        : isLow
        ? Icons.warning_amber_rounded
        : Icons.check_circle_rounded;

    String formattedExpiry = expiry;
    if (expiryDate != null) {
      formattedExpiry =
          '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 10),
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: stockId == 0
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockTotalDetail(stockId: stockId),
                  ),
                ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpired
                    ? _C.amber.withValues(alpha: 0.5)
                    : isLow
                    ? _C.rose.withValues(alpha: 0.4)
                    : _C.divider,
              ),
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
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: badgeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.isNotEmpty ? drug : 'Unknown Drug',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_rounded,
                            size: 11,
                            color: _C.textSub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Batch: $batch',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: _C.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: isExpired ? _C.amber : _C.textSub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedExpiry.isNotEmpty
                                ? 'Expiry: $formattedExpiry'
                                : 'No expiry',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: isExpired ? _C.amber : _C.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$qty',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 10, color: badgeColor),
                          const SizedBox(width: 3),
                          Text(
                            badgeLabel,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _C.indigoSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: _C.indigo,
                      ),
                    ),
                  ],
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
              'Failed to load stock list',
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
              onTap: _reloadList,
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
              Icons.inventory_2_rounded,
              size: 38,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Stock Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search',
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
    final filtered = _filtered;
    final hp = _hPad;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Stock Display',
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
                      _headerCard(),
                      const SizedBox(height: 18),
                      _overviewSection(),
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
                              'Stock List',
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
                                  '${filtered.length}',
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
                      (_, __) => _shimmerStockCard(),
                      childCount: 6,
                    ),
                  )
                else if (_listError != null)
                  SliverToBoxAdapter(child: _listErrorWidget())
                else if (filtered.isEmpty)
                  SliverToBoxAdapter(child: _emptyWidget())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => FadeTransition(
                        opacity: _fadeAnim,
                        child: _stockCard(filtered[i]),
                      ),
                      childCount: filtered.length,
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
