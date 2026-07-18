import 'dart:async';
import 'package:drug_tracking_system/core/services/api_service/invoice_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'invoice_detail_screen.dart';

class _C {
  static const bg = Color(0xFFF4F2FB);
  static const surface = Color(0xFFFFFFFF);
  static const purple = Color(0xFF8640F6);
  static const purpleSoft = Color(0xFFEDE8FB);
  static const purpleDim = Color(0xFFD5C8F8);
  static const textPrimary = Color(0xFF1A1035);
  static const textSub = Color(0xFF7B7494);
  static const divider = Color(0xFFE5E0F5);
  static const shadow = Color(0x14602EE8);
  static const accept = Color(0xFF00B87A);
  static const acceptBg = Color(0xFFE6F9F2);
  static const reject = Color(0xFFE8455A);
  static const rejectBg = Color(0xFFFDECEF);
  static const pending = Color(0xFFF59E0B);
  static const pendingBg = Color(0xFFFFF8EC);
}

enum InvoiceFilter { all, pending, accepted, rejected }

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;
  bool _isReloading = false;
  InvoiceFilter _activeFilter = InvoiceFilter.all;
  String _searchQuery = '';

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

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
    _loadInvoices();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices({bool reload = false}) async {
    if (!mounted) return;
    if (reload) {
      if (_isReloading) return;
      setState(() => _isReloading = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final data = await InvoiceApi.getIncomingInvoices();
      if (!mounted) return;
      final parsed = data
          .map<Map<String, dynamic>>((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'invoice_id':
                  int.tryParse(m['invoice_id']?.toString() ?? '0') ?? 0,
              'invoice_number': m['invoice_number']?.toString() ?? '',
              'invoice_date': m['invoice_date']?.toString() ?? '',
              'created_at': m['created_at']?.toString() ?? '',
              'status': m['status']?.toString().toLowerCase() ?? 'pending',
              'total_amount':
                  double.tryParse(m['total_amount']?.toString() ?? '0') ?? 0.0,
              'wholesaler_name': m['wholesaler_name']?.toString() ?? 'Unknown',
              'shop_name': m['shop_name']?.toString() ?? '',
              'drug_license_no': m['drug_license_no']?.toString() ?? '',
              'phone': m['phone']?.toString() ?? '',
              'email': m['email']?.toString() ?? '',
            };
          })
          .where((e) => e['invoice_id'] != 0)
          .toList();

      setState(() {
        _invoices = parsed;
        _isLoading = false;
        _isReloading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isReloading = false;
      });
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.reject,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    }
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _searchQuery = val.trim());
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _invoices.where((inv) {
      final matchFilter =
          _activeFilter == InvoiceFilter.all ||
          (_activeFilter == InvoiceFilter.pending &&
              inv['status'] == 'pending') ||
          (_activeFilter == InvoiceFilter.accepted &&
              inv['status'] == 'accepted') ||
          (_activeFilter == InvoiceFilter.rejected &&
              inv['status'] == 'rejected');
      final matchSearch =
          q.isEmpty ||
          inv['invoice_number'].toString().toLowerCase().contains(q) ||
          inv['wholesaler_name'].toString().toLowerCase().contains(q) ||
          inv['shop_name'].toString().toLowerCase().contains(q) ||
          inv['status'].toString().toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  int get _pendingCount =>
      _invoices.where((i) => i['status'] == 'pending').length;
  int get _acceptedCount =>
      _invoices.where((i) => i['status'] == 'accepted').length;
  int get _rejectedCount =>
      _invoices.where((i) => i['status'] == 'rejected').length;

  String _fmtDate(String? v) {
    if (v == null || v.trim().isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  String _fmtDateTime(String? v) {
    if (v == null || v.trim().isEmpty) return '—';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  Color _statusColor(String s) => s == 'accepted'
      ? _C.accept
      : s == 'rejected'
      ? _C.reject
      : _C.pending;

  Color _statusBg(String s) => s == 'accepted'
      ? _C.acceptBg
      : s == 'rejected'
      ? _C.rejectBg
      : _C.pendingBg;

  IconData _statusIcon(String s) => s == 'accepted'
      ? Icons.check_circle_rounded
      : s == 'rejected'
      ? Icons.cancel_rounded
      : Icons.access_time_rounded;

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.22;
    if (w > 900) return w * 0.14;
    if (w > 600) return w * 0.07;
    return 16;
  }

  Widget _shimmerBox({
    double width = double.infinity,
    double height = 14,
    double radius = 8,
  }) {
    return _ShimmerBox(width: width, height: height, radius: radius);
  }

  Widget _skeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: _C.purpleSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                _shimmerBox(width: 46, height: 46, radius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: 140, height: 14),
                      const SizedBox(height: 8),
                      _shimmerBox(width: 100, height: 11),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _shimmerBox(width: 72, height: 28, radius: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.purpleSoft.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.purple.withOpacity(0.10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 100, height: 11),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 180, height: 14),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 140, height: 11),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 120, height: 11),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(
                        width: double.infinity,
                        height: 56,
                        radius: 14,
                      ),
                      const SizedBox(height: 8),
                      _shimmerBox(width: 160, height: 11),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _shimmerBox(width: 48, height: 48, radius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonSummary() {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.divider),
              boxShadow: [
                BoxShadow(
                  color: _C.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _shimmerBox(width: 40, height: 40, radius: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: 30, height: 20),
                      const SizedBox(height: 6),
                      _shimmerBox(width: 50, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _summaryCard(
    String label,
    int count,
    Color color,
    Color bg,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count',
                      style: GoogleFonts.nunito(
                        color: _C.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: _C.textSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, InvoiceFilter filter, Color activeColor) {
    final sel = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? activeColor : _C.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: sel ? activeColor : _C.divider, width: 1.5),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: sel ? Colors.white : _C.textSub,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? iconColor}) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: iconColor ?? _C.purple.withOpacity(0.65)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: _C.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceCard(Map<String, dynamic> inv) {
    final status = inv['status'].toString();
    final total = inv['total_amount'] as double;
    final accent = _statusColor(status);
    final accentBg = _statusBg(status);
    final statusLabel = status[0].toUpperCase() + status.substring(1);

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: () async {
          await Get.to(() => InvoiceDetailScreen(invoiceId: inv['invoice_id']));
          _loadInvoices(reload: true);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.divider),
            boxShadow: [
              BoxShadow(
                color: _C.shadow,
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: _C.purpleSoft,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _C.purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: _C.purple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv['invoice_number'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              color: _C.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: _C.textSub,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmtDate(inv['invoice_date']),
                                style: GoogleFonts.nunito(
                                  color: _C.textSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accentBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accent.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status), color: accent, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel.toUpperCase(),
                            style: GoogleFonts.nunito(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.purpleSoft.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _C.purple.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.store_rounded,
                            size: 14,
                            color: _C.purple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'From Wholesaler',
                            style: GoogleFonts.nunito(
                              color: _C.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        inv['wholesaler_name'],
                        style: GoogleFonts.nunito(
                          color: _C.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((inv['shop_name'] as String).isNotEmpty)
                        const SizedBox(height: 6),
                      _infoRow(Icons.business_rounded, inv['shop_name']),
                      _infoRow(
                        Icons.verified_rounded,
                        (inv['drug_license_no'] as String).isNotEmpty
                            ? 'License: ${inv['drug_license_no']}'
                            : '',
                        iconColor: _C.accept,
                      ),
                      _infoRow(Icons.phone_rounded, inv['phone']),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _C.acceptBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _C.accept.withOpacity(0.18),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: GoogleFonts.nunito(
                                    color: _C.textSub,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${total.toStringAsFixed(2)}',
                                  style: GoogleFonts.nunito(
                                    color: _C.accept,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: _C.textSub,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Received: ${_fmtDateTime(inv['created_at'])}',
                                  style: GoogleFonts.nunito(
                                    color: _C.textSub,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _C.purple,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _C.purple.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.purpleSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: _C.purple.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No invoices found',
            style: GoogleFonts.nunito(
              color: _C.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter',
            style: GoogleFonts.nunito(color: _C.textSub, fontSize: 13),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
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
              color: _C.purple,
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

  @override
  Widget build(BuildContext context) {
    final hp = _hPad;
    final filtered = _filtered;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Incoming Invoices',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(height: 24, color: _C.bg),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('Overview'),
                    _isLoading
                        ? _skeletonSummary()
                        : Row(
                            children: [
                              _summaryCard(
                                'Pending',
                                _pendingCount,
                                _C.pending,
                                _C.pendingBg,
                                Icons.access_time_rounded,
                              ),
                              const SizedBox(width: 8),
                              _summaryCard(
                                'Accepted',
                                _acceptedCount,
                                _C.accept,
                                _C.acceptBg,
                                Icons.check_circle_rounded,
                              ),
                              const SizedBox(width: 8),
                              _summaryCard(
                                'Rejected',
                                _rejectedCount,
                                _C.reject,
                                _C.rejectBg,
                                Icons.cancel_rounded,
                              ),
                            ],
                          ),

                    const SizedBox(height: 16),

                    _sectionLabel('Search'),
                    Container(
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.divider, width: 1.2),
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
                          color: _C.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search by invoice no., wholesaler, shop...',
                          hintStyle: GoogleFonts.nunito(
                            color: _C.textSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _C.purple.withOpacity(0.7),
                            size: 20,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
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
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _sectionLabel('Filter'),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _filterChip(
                            'All (${_invoices.length})',
                            InvoiceFilter.all,
                            _C.purple,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Pending ($_pendingCount)',
                            InvoiceFilter.pending,
                            _C.pending,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Accepted ($_acceptedCount)',
                            InvoiceFilter.accepted,
                            _C.accept,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Rejected ($_rejectedCount)',
                            InvoiceFilter.rejected,
                            _C.reject,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _C.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Results',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _C.purpleSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${filtered.length}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _C.purple,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _isReloading
                              ? null
                              : () => _loadInvoices(reload: true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _C.purpleSoft,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _C.purple.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isReloading)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: _C.purple,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                    color: _C.purple,
                                  ),
                                const SizedBox(width: 5),
                                Text(
                                  'Reload',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _C.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ]),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 30),
                sliver: _isLoading
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => _skeletonCard(),
                          childCount: 4,
                        ),
                      )
                    : filtered.isEmpty
                    ? _emptyState()
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _invoiceCard(filtered[i]),
                          childCount: filtered.length,
                        ),
                      ),
              ),
            ],
          ),
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
    required this.radius,
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
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFDDD8F0),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
