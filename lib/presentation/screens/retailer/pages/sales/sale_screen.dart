import 'dart:async';
import 'dart:io';
import 'package:drug_tracking_system/core/services/api_service/retailer_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _T {
  static const bg = Color(0xFFF7F5FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0EDFB);
  static const primary = Color(0xFF6C2EF2);
  static const primaryDark = Color(0xFF4A1BAB);
  static const primarySoft = Color(0xFFEDE8FB);
  static const primaryMid = Color(0xFFD4C7F9);
  static const success = Color(0xFF059669);
  static const successSoft = Color(0xFFD1FAE5);
  static const error = Color(0xFFDC2626);
  static const errorSoft = Color(0xFFFEE2E2);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF3C7);
  static const info = Color(0xFF0284C7);
  static const textPrimary = Color(0xFF0F0A1E);
  static const textSub = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE9E4F8);
  static const shadow = Color(0x186C2EF2);
  static const inputBg = Color(0xFFF3F0FD);
}

class _Snack {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color bg = isError
        ? _T.error
        : isSuccess
        ? _T.success
        : isWarning
        ? _T.warning
        : _T.primary;

    final IconData icon = isError
        ? Icons.error_rounded
        : isSuccess
        ? Icons.check_circle_rounded
        : isWarning
        ? Icons.warning_amber_rounded
        : Icons.info_rounded;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
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

class _Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Skeleton({
    this.width = double.infinity,
    this.height = 16,
    this.radius = 10,
  });

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                const Color(0xFFE5E0F5),
                const Color(0xFFD0C8EE),
                _ctrl.value,
              )!,
              Color.lerp(
                const Color(0xFFD0C8EE),
                const Color(0xFFE5E0F5),
                _ctrl.value,
              )!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SellItem {
  int? batchId;
  int availableQty = 0;
  double mrp = 0;
  String drugName = '';
  String batchNo = '';
  double total = 0;
  String? expiryDate;

  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }

  void recalc() {
    final q = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    final p = double.tryParse(priceCtrl.text.trim()) ?? 0;
    total = q * p;
  }

  String? validate() {
    if (batchId == null) return 'Select a product batch';
    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    if (qty <= 0) return 'Enter a valid quantity';
    if (price <= 0) return 'Enter a valid selling price';
    if (qty > availableQty)
      return 'Quantity exceeds available stock ($availableQty units)';
    if (price > mrp)
      return 'Selling price exceeds MRP (₹${mrp.toStringAsFixed(2)})';
    return null;
  }
}

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _stock = [];
  final List<_SellItem> _items = [];
  String _paymentMode = 'Cash';
  bool _isLoading = true;
  bool _isSubmitting = false;

  final _patientCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _abhaCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  bool _animReady = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _animReady = true;
    _fadeCtrl.value = 1.0;
    _addItem();
    _loadStock();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _patientCtrl.dispose();
    _mobileCtrl.dispose();
    _doctorCtrl.dispose();
    _abhaCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStock() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await RetailerApi.getStock();
      if (!mounted) return;
      setState(() {
        _stock = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
      if (_animReady) _fadeCtrl.forward(from: 0);
    } on SocketException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMsg(
        'No internet connection. Please check your network.',
        isError: true,
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMsg('Connection timed out. Please try again.', isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMsg(e.toString().replaceAll('Exception:', '').trim(), isError: true);
    }
  }

  void _addItem() {
    setState(() => _items.add(_SellItem()));
  }

  void _removeItem(int i) {
    if (_items.length <= 1) return;
    _items[i].dispose();
    setState(() => _items.removeAt(i));
  }

  void _recalc(int i) => setState(() => _items[i].recalc());

  Future<void> _selectBatch(int i) async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BatchSheet(stock: _stock),
    );
    if (result == null || !mounted) return;
    setState(() {
      final item = _items[i];
      item.batchId = result['batch_id'] as int?;
      item.availableQty = (result['quantity'] as num?)?.toInt() ?? 0;
      item.mrp = double.tryParse(result['mrp'].toString()) ?? 0;
      item.drugName = result['drug_name']?.toString() ?? '';
      item.batchNo = result['batch_no']?.toString() ?? '';
      item.expiryDate = result['expiry_date']?.toString();
      item.qtyCtrl.clear();
      item.priceCtrl.clear();
      item.total = 0;
    });
  }

  double get _grandTotal => _items.fold(0.0, (s, e) => s + e.total);

  String _formatAbha(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length != 14) return raw;
    return '${d.substring(0, 2)}-${d.substring(2, 6)}-${d.substring(6, 10)}-${d.substring(10, 14)}';
  }

  void _showMsg(
    String msg, {
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    if (!mounted) return;
    _Snack.show(
      context,
      msg,
      isError: isError,
      isSuccess: isSuccess,
      isWarning: isWarning,
    );
  }

  Future<void> _sell() async {
    FocusScope.of(context).unfocus();

    if (_patientCtrl.text.trim().isEmpty) {
      _showMsg('Patient name is required', isError: true);
      return;
    }
    final mobile = _mobileCtrl.text.trim();
    if (mobile.isNotEmpty && mobile.length != 10) {
      _showMsg('Enter a valid 10-digit mobile number', isError: true);
      return;
    }
    if (_abhaCtrl.text.trim().isEmpty) {
      _showMsg('ABHA ID is required', isError: true);
      return;
    }
    if (_abhaCtrl.text.replaceAll(RegExp(r'\D'), '').length != 14) {
      _showMsg('ABHA ID must be 14 digits', isError: true);
      return;
    }

    for (int i = 0; i < _items.length; i++) {
      final err = _items[i].validate();
      if (err != null) {
        _showMsg('Item ${i + 1}: $err', isError: true);
        return;
      }
    }

    final payload = _items
        .map(
          (item) => {
            'batch_id': item.batchId,
            'quantity': int.parse(item.qtyCtrl.text.trim()),
            'price': double.parse(item.priceCtrl.text.trim()),
          },
        )
        .toList();

    setState(() => _isSubmitting = true);

    try {
      final response = await RetailerApi.sellProduct(
        items: payload,
        patientName: _patientCtrl.text.trim(),
        abhaId: _formatAbha(_abhaCtrl.text.trim()),
        patientMobile: _mobileCtrl.text.trim(),
        doctorName: _doctorCtrl.text.trim(),
        paymentMode: _paymentMode,
      );
      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Sale failed. Please try again.',
        );
      }
      _showMsg(
        response['message'] ?? '${_items.length} product(s) sold successfully!',
        isSuccess: true,
      );
      _resetForm();
      await _loadStock();
    } on SocketException {
      _showMsg(
        'No internet connection. Check your network and retry.',
        isError: true,
      );
    } on TimeoutException {
      _showMsg('Request timed out. Please try again.', isError: true);
    } on FormatException {
      _showMsg(
        'Unexpected server response. Please contact support.',
        isError: true,
      );
    } catch (e) {
      _showMsg(e.toString().replaceAll('Exception:', '').trim(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _patientCtrl.clear();
    _mobileCtrl.clear();
    _doctorCtrl.clear();
    _abhaCtrl.clear();
    for (final item in _items) {
      item.dispose();
    }
    setState(() {
      _items.clear();
      _paymentMode = 'Cash';
    });
    _addItem();
    if (_animReady) _fadeCtrl.forward(from: 0);
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16.0;
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    void Function(String)? onChanged,
    Color? iconColor,
    String? hint,
    bool isRequired = false,
    TextInputAction action = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _T.inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.divider, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        textInputAction: action,
        inputFormatters: formatters,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          color: _T.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          labelStyle: GoogleFonts.inter(
            color: _T.textSub,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(color: _T.textMuted, fontSize: 13),
          prefixIcon: Icon(
            icon,
            color: (iconColor ?? _T.primary).withOpacity(0.65),
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: _T.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _T.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: _T.primary),
                const SizedBox(width: 5),
              ],
              Text(
                text,
                style: GoogleFonts.inter(
                  color: _T.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: color.withOpacity(0.75),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(int index) {
    final item = _items[index];
    final bool selected = item.batchId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? _T.primaryMid : _T.divider,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _T.shadow,
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: selected ? _T.primarySoft : _T.surfaceAlt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _T.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.medication_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ITEM ${index + 1}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_items.length > 1)
                  GestureDetector(
                    onTap: () => _removeItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _T.errorSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _T.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: _T.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Remove',
                            style: GoogleFonts.inter(
                              color: _T.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _selectBatch(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _T.primarySoft : _T.inputBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? _T.primary.withOpacity(0.35)
                            : _T.divider,
                        width: selected ? 1.5 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected
                                ? _T.primary.withOpacity(0.12)
                                : _T.divider.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: selected ? _T.primary : _T.textMuted,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BATCH / DRUG',
                                style: GoogleFonts.inter(
                                  color: _T.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                selected
                                    ? '${item.drugName}  •  ${item.batchNo}'
                                    : 'Tap to choose a batch',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: selected ? _T.textPrimary : _T.textSub,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.swap_horiz_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _T.primary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _badge(
                          'AVAILABLE',
                          '${item.availableQty} units',
                          item.availableQty < 20 ? _T.error : _T.success,
                          item.availableQty < 20
                              ? _T.errorSoft
                              : _T.successSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _badge(
                          'MRP',
                          '₹${item.mrp.toStringAsFixed(2)}',
                          _T.warning,
                          _T.warningSoft,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _input(
                  controller: item.qtyCtrl,
                  label: 'Quantity',
                  icon: Icons.production_quantity_limits_rounded,
                  type: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _recalc(index),
                  hint: 'e.g. 5',
                ),
                const SizedBox(height: 10),
                _input(
                  controller: item.priceCtrl,
                  label: 'Selling Price (₹)',
                  icon: Icons.currency_rupee_rounded,
                  type: const TextInputType.numberWithOptions(decimal: true),
                  formatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) => _recalc(index),
                  iconColor: _T.success,
                  hint: item.mrp > 0
                      ? 'Max ₹${item.mrp.toStringAsFixed(2)}'
                      : null,
                ),
                if (item.total > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C2EF2), Color(0xFF4A1BAB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _T.primary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Item Total',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${item.total.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: _T.shadow,
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            'PATIENT & PAYMENT INFO',
            icon: Icons.person_pin_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _T.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.divider, width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _paymentMode,
                isExpanded: true,
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: _T.primary.withOpacity(0.6),
                ),
                style: GoogleFonts.inter(
                  color: _T.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: _T.surface,
                borderRadius: BorderRadius.circular(14),
                items: ['Cash', 'Online', 'Card'].map((v) {
                  final icons = {
                    'Cash': Icons.money_rounded,
                    'Online': Icons.phone_android_rounded,
                    'Card': Icons.credit_card_rounded,
                  };
                  final colors = {
                    'Cash': _T.success,
                    'Online': _T.info,
                    'Card': _T.warning,
                  };
                  return DropdownMenuItem(
                    value: v,
                    child: Row(
                      children: [
                        Icon(
                          icons[v],
                          color: colors[v]?.withOpacity(0.8),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          v,
                          style: GoogleFonts.inter(
                            color: _T.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _paymentMode = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _input(
            controller: _patientCtrl,
            label: 'Patient Name',
            icon: Icons.person_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 10),
          _input(
            controller: _mobileCtrl,
            label: 'Mobile Number',
            icon: Icons.phone_rounded,
            type: TextInputType.phone,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            hint: '10-digit number',
          ),
          const SizedBox(height: 10),
          _input(
            controller: _abhaCtrl,
            label: 'ABHA ID',
            icon: Icons.badge_rounded,
            type: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
            hint: '14-digit ABHA number',
            isRequired: true,
          ),
          const SizedBox(height: 10),
          _input(
            controller: _doctorCtrl,
            label: 'Doctor Name',
            icon: Icons.local_hospital_rounded,
            action: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _skeletonItemCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _T.surfaceAlt,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: const Row(
              children: [_Skeleton(width: 68, height: 22, radius: 11)],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _Skeleton(height: 66, radius: 14),
                SizedBox(height: 12),
                _Skeleton(height: 52, radius: 14),
                SizedBox(height: 10),
                _Skeleton(height: 52, radius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonPatientCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.divider),
      ),
      child: const Column(
        children: [
          _Skeleton(width: 200, height: 28, radius: 8),
          SizedBox(height: 18),
          _Skeleton(height: 52, radius: 14),
          SizedBox(height: 10),
          _Skeleton(height: 52, radius: 14),
          SizedBox(height: 10),
          _Skeleton(height: 52, radius: 14),
          SizedBox(height: 10),
          _Skeleton(height: 52, radius: 14),
          SizedBox(height: 10),
          _Skeleton(height: 52, radius: 14),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hp = _hPad(context);
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _T.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
          'Sell Products',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Stock',
            onPressed: _isLoading ? null : _loadStock,
            icon: AnimatedRotation(
              turns: _isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white.withOpacity(_isLoading ? 0.4 : 0.9),
                size: 22,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoading
            ? _buildSkeleton(hp)
            : SafeArea(
                child: RefreshIndicator(
                  color: _T.primary,
                  backgroundColor: _T.surface,
                  onRefresh: _loadStock,
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          hp,
                          16,
                          hp,
                          mq.viewInsets.bottom + 80,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _T.primarySoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.receipt_long_rounded,
                                        size: 12,
                                        color: _T.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${_items.length} item${_items.length != 1 ? "s" : ""} in this sale',
                                        style: GoogleFonts.inter(
                                          color: _T.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(_items.length, _itemCard),
                            GestureDetector(
                              onTap: _addItem,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _T.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _T.primary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _T.shadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _T.primarySoft,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: _T.primary,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Add Another Item',
                                      style: GoogleFonts.inter(
                                        color: _T.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _patientCard(),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                18,
                                20,
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: _T.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _T.divider),
                                boxShadow: [
                                  BoxShadow(
                                    color: _T.shadow,
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _T.primarySoft,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.calculate_rounded,
                                      color: _T.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GRAND TOTAL',
                                        style: GoogleFonts.inter(
                                          color: _T.textSub,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_items.length} item${_items.length != 1 ? "s" : ""}  •  $_paymentMode',
                                        style: GoogleFonts.inter(
                                          color: _T.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${_grandTotal.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      color: _T.textPrimary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedOpacity(
                              opacity: _isSubmitting ? 0.75 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: GestureDetector(
                                onTap: _isSubmitting ? null : _sell,
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF059669),
                                        Color(0xFF047857),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: _isSubmitting
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: _T.success.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 7),
                                            ),
                                          ],
                                  ),
                                  child: _isSubmitting
                                      ? const Center(
                                          child: SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons
                                                  .shopping_cart_checkout_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Confirm Sale',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton(double hp) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hp, 16, hp, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Skeleton(width: 150, height: 28, radius: 8),
          const SizedBox(height: 16),
          _skeletonItemCard(),
          _skeletonItemCard(),
          const _Skeleton(height: 52, radius: 16),
          const SizedBox(height: 20),
          _skeletonPatientCard(),
          const SizedBox(height: 20),
          const _Skeleton(height: 80, radius: 20),
          const SizedBox(height: 14),
          const _Skeleton(height: 58, radius: 18),
        ],
      ),
    );
  }
}

class _BatchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> stock;
  const _BatchSheet({required this.stock});

  @override
  State<_BatchSheet> createState() => _BatchSheetState();
}

class _BatchSheetState extends State<_BatchSheet> {
  late final TextEditingController _search;
  late final ValueNotifier<List<Map<String, dynamic>>> _filtered;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _filtered = ValueNotifier(List.from(widget.stock));
  }

  @override
  void dispose() {
    _search.dispose();
    _filtered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: _T.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _T.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _T.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: _T.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Batch',
                            style: GoogleFonts.inter(
                              color: _T.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${widget.stock.length} batches available',
                            style: GoogleFonts.inter(
                              color: _T.textSub,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _T.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _T.divider),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _T.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _T.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _T.divider, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: _T.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _search,
                    autofocus: false,
                    style: GoogleFonts.inter(
                      color: _T.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by drug name or batch...',
                      hintStyle: GoogleFonts.inter(
                        color: _T.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _T.primary.withOpacity(0.55),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 4,
                      ),
                    ),
                    onChanged: (v) {
                      final q = v.trim().toLowerCase();
                      _filtered.value = q.isEmpty
                          ? List.from(widget.stock)
                          : widget.stock
                                .where(
                                  (e) =>
                                      e['drug_name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(q) ||
                                      e['batch_no']
                                          .toString()
                                          .toLowerCase()
                                          .contains(q),
                                )
                                .toList();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _filtered,
                    builder: (_, list, __) {
                      if (list.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: _T.primarySoft,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.medication_outlined,
                                  color: _T.primary.withOpacity(0.4),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No batch found',
                                style: GoogleFonts.inter(
                                  color: _T.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term',
                                style: GoogleFonts.inter(
                                  color: _T.textSub,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: sc,
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final b = list[i];
                          final int qty = (b['quantity'] as num?)?.toInt() ?? 0;
                          final double mrp =
                              double.tryParse(b['mrp'].toString()) ?? 0;
                          final bool low = qty < 20;
                          final Color stockClr = low ? _T.error : _T.success;
                          final Color stockBg = low
                              ? _T.errorSoft
                              : _T.successSoft;

                          return GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(b),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _T.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _T.divider),
                                boxShadow: [
                                  BoxShadow(
                                    color: _T.shadow,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: _T.primarySoft,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.medication_rounded,
                                      color: _T.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b['drug_name']?.toString() ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: _T.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Batch: ${b["batch_no"]}',
                                          style: GoogleFonts.inter(
                                            color: _T.textSub,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if ((b['strength'] ?? '')
                                            .toString()
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${b["strength"]}${b["dosage_form"] != null && b["dosage_form"].toString().isNotEmpty ? " · ${b["dosage_form"]}" : ""}',
                                            style: GoogleFonts.inter(
                                              color: _T.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 2),
                                        Text(
                                          'MRP ₹${mrp.toStringAsFixed(2)}',
                                          style: GoogleFonts.inter(
                                            color: _T.warning,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        qty.toString(),
                                        style: GoogleFonts.inter(
                                          color: stockClr,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: stockBg,
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          border: Border.all(
                                            color: stockClr.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          low ? 'LOW' : 'OK',
                                          style: GoogleFonts.inter(
                                            color: stockClr,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
