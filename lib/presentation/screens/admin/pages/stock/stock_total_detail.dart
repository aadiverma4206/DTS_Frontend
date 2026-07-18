import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFEF3C7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const teal = Color(0xFF0F766E);
  static const tealSoft = Color(0xFFCCFBF1);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHigh = Color(0xFFF1F5F9);
}

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Shimmer({
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}
String _formatDateTime(dynamic value) {
  if (value == null) return '-';

  try {
    final date = DateTime.parse(value.toString());

    return DateFormat(
      'dd/MM/yyyy hh:mm a',
    ).format(date.toLocal());

  } catch (e) {
    return value.toString();
  }
}
class _ShimmerState extends State<_Shimmer>
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
              Color.lerp(_C.shimmerBase, _C.shimmerHigh, _anim.value)!,
              Color.lerp(_C.shimmerHigh, _C.shimmerBase, _anim.value)!,
            ],
          ),
        ),
      ),
    );
  }
}

enum _Filter {
  all,
  drug,
  batch,
  pricing,
  manufacturer,
  wholesaler,
  retailer,
  supplier,
}

extension _FilterMeta on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.drug:
        return 'Drug Info';
      case _Filter.batch:
        return 'Batch';
      case _Filter.pricing:
        return 'Pricing';
      case _Filter.manufacturer:
        return 'Manufacturer';
      case _Filter.wholesaler:
        return 'Wholesaler';
      case _Filter.retailer:
        return 'Retailer';
      case _Filter.supplier:
        return 'Supplier';
    }
  }

  IconData get icon {
    switch (this) {
      case _Filter.all:
        return Icons.grid_view_rounded;
      case _Filter.drug:
        return Icons.medication_rounded;
      case _Filter.batch:
        return Icons.inventory_2_rounded;
      case _Filter.pricing:
        return Icons.currency_rupee_rounded;
      case _Filter.manufacturer:
        return Icons.factory_rounded;
      case _Filter.wholesaler:
        return Icons.local_shipping_rounded;
      case _Filter.retailer:
        return Icons.store_rounded;
      case _Filter.supplier:
        return Icons.warehouse_rounded;
    }
  }

  Color get activeColor {
    switch (this) {
      case _Filter.all:
        return _C.indigo;
      case _Filter.drug:
        return _C.purple;
      case _Filter.batch:
        return _C.amber;
      case _Filter.pricing:
        return _C.green;
      case _Filter.manufacturer:
        return _C.blue;
      case _Filter.wholesaler:
        return _C.teal;
      case _Filter.retailer:
        return _C.rose;
      case _Filter.supplier:
        return const Color(0xFF92400E);
    }
  }

  Color get softColor {
    switch (this) {
      case _Filter.all:
        return _C.indigoSoft;
      case _Filter.drug:
        return _C.purpleSoft;
      case _Filter.batch:
        return _C.amberSoft;
      case _Filter.pricing:
        return _C.greenSoft;
      case _Filter.manufacturer:
        return _C.blueSoft;
      case _Filter.wholesaler:
        return _C.tealSoft;
      case _Filter.retailer:
        return _C.roseSoft;
      case _Filter.supplier:
        return const Color(0xFFFEF3C7);
    }
  }
}

class StockTotalDetail extends StatefulWidget {
  final int stockId;

  const StockTotalDetail({super.key, required this.stockId});

  @override
  State<StockTotalDetail> createState() => _StockTotalDetailState();
}

class _StockTotalDetailState extends State<StockTotalDetail> {
  Map<String, dynamic> stock = {};
  bool isLoading = true;
  bool hasError = false;
  String errorMsg = '';
  _Filter _activeFilter = _Filter.all;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
      errorMsg = '';
    });
    try {
      final response = await AdminApi.getStockDetail(widget.stockId);
      if (!mounted) return;
      final data = response["data"] is Map<String, dynamic>
          ? response["data"]
          : response;
      setState(() {
        stock = Map<String, dynamic>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
        errorMsg = e.toString();
      });
    }
  }

  String _val(dynamic data) {
    if (data == null) return '-';
    final t = data.toString().trim();
    return (t.isEmpty || t.toLowerCase() == 'null') ? '-' : t;
  }

  bool get _isWholesaler => stock['role_name'] == 'wholesaler';
  bool get _isRetailer => stock['role_name'] == 'retailer';
  bool get _hasSupplier => stock['supplier_wholesaler'] != null;

  List<_Filter> get _availableFilters {
    final filters = [
      _Filter.all,
      _Filter.drug,
      _Filter.batch,
      _Filter.pricing,
      _Filter.manufacturer,
    ];
    if (!isLoading) {
      if (_isWholesaler) filters.add(_Filter.wholesaler);
      if (_isRetailer) filters.add(_Filter.retailer);
      if (_hasSupplier) filters.add(_Filter.supplier);
    }
    return filters;
  }

  bool _shouldShow(_Filter section) =>
      _activeFilter == _Filter.all || _activeFilter == section;

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(
            _val(stock['drug_name']),
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _val(stock['composition']),
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          _pdfSection('Drug Information', [
            ['Drug Name', stock['drug_name']],
            ['Composition', stock['composition']],
            ['Category', stock['category']],
            ['Dosage Form', stock['dosage_form']],
            ['Strength', stock['strength']],
            ['Narcotic', stock['is_narcotic'] == 1 ? 'Yes' : 'No'],
          ]),
          _pdfSection('Batch Information', [
            ['Batch Number', stock['batch_no']],
            ['Manufacture Date', stock['manufacture_date']],
            ['Expiry Date', stock['expiry_date']],
            ['Batch Status', stock['batch_status']],
          ]),
          _pdfSection('Pricing Information', [
            ['Manufacturer Price', stock['manufacturer_price']],
            ['Wholesaler Price', stock['wholesaler_price']],
            ['Retailer Price', stock['retailer_price']],
          ]),
          _pdfSection('Manufacturer Detail', [
            ['Company Name', stock['manufacturer_name']],
            ['Drug License', stock['manufacturer_license']],
            ['GSTIN', stock['manufacturer_gstin']],
            ['PAN Number', stock['manufacturer_pan']],
            ['CIN Number', stock['manufacturer_cin']],
            ['Phone', stock['manufacturer_phone']],
            ['Email', stock['manufacturer_email']],
            ['Website', stock['manufacturer_website']],
            ['Address', stock['manufacturer_address']],
          ]),
          if (_isWholesaler)
            _pdfSection('Wholesaler Detail', [
              ['Company Name', stock['wholesaler_name']],
              ['Drug License', stock['wholesaler_license']],
              ['GSTIN', stock['wholesaler_gstin']],
              ['Phone', stock['wholesaler_phone']],
              ['Email', stock['wholesaler_email']],
              ['Address', stock['wholesaler_address']],
              ['Owner Name', stock['user_name']],
              ['Mobile', stock['mobile']],
            ]),
          if (_isRetailer)
            _pdfSection('Retailer Detail', [
              ['Shop Name', stock['retailer_shop_name']],
              ['Drug License', stock['retailer_license']],
              ['GSTIN', stock['retailer_gstin']],
              ['Phone', stock['retailer_phone']],
              ['Email', stock['retailer_email']],
              ['Address', stock['retailer_address']],
              ['Owner Name', stock['user_name']],
              ['Mobile', stock['mobile']],
            ]),
          if (_hasSupplier)
            _pdfSection('Supplier Wholesaler', [
              ['Company Name', stock['supplier_wholesaler']['company_name']],
              ['Drug License', stock['supplier_wholesaler']['drug_license_no']],
              ['GSTIN', stock['supplier_wholesaler']['gstin']],
              ['Phone', stock['supplier_wholesaler']['phone']],
              ['Email', stock['supplier_wholesaler']['email']],
              ['Address', stock['supplier_wholesaler']['address']],
              ['Owner Name', stock['supplier_wholesaler']['owner_name']],
              ['Owner Mobile', stock['supplier_wholesaler']['owner_mobile']],
            ]),
        ],
      ),
    );
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: '${_val(stock['drug_name'])}_stock_detail.pdf',
    );
  }

  pw.Widget _pdfSection(String title, List<List<dynamic>> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepPurple,
          ),
        ),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        ...rows.map(
          (r) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 140,
                  child: pw.Text(
                    _val(r[0]),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    _val(r[1]),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, dynamic data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textSub,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLoading
                ? const _Shimmer(height: 13, radius: 6)
                : Text(
                    _val(data),
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: iconColor.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    final isNarcotic = stock['is_narcotic'] == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const Spacer(),
                    isLoading
                        ? Container(
                            width: 90,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const _Shimmer(radius: 30),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isNarcotic
                                  ? _C.rose.withValues(alpha: 0.9)
                                  : _C.green.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: (isNarcotic ? _C.rose : _C.green)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNarcotic
                                      ? Icons.warning_rounded
                                      : Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isNarcotic ? 'NARCOTIC' : 'NORMAL',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                isLoading
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const _Shimmer(radius: 8),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 180,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const _Shimmer(radius: 6),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _val(stock['drug_name']),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _val(stock['composition']),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 14),
                isLoading
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          3,
                          (_) => Container(
                            width: 86,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const _Shimmer(radius: 40),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(
                            Icons.inventory_2_outlined,
                            'Qty ${_val(stock['quantity'])}',
                          ),
                          _chip(
                            _isRetailer
                                ? Icons.storefront_rounded
                                : Icons.local_shipping_rounded,
                            _val(stock['role_name']).toUpperCase(),
                          ),
                          _chip(
                            Icons.category_outlined,
                            _val(stock['category']),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    final filters = _availableFilters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: _C.indigo,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Filter Sections',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 1),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = filters[i];
              final isActive = _activeFilter == f;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? f.activeColor : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? f.activeColor : _C.divider,
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: f.activeColor.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            const BoxShadow(
                              color: _C.shadow,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isActive ? 0 : 22,
                        height: isActive ? 0 : 22,
                        decoration: isActive
                            ? null
                            : BoxDecoration(
                                color: f.softColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                        child: isActive
                            ? null
                            : Icon(f.icon, size: 12, color: f.activeColor),
                      ),
                      if (!isActive) const SizedBox(width: 6),
                      if (isActive) ...[
                        Icon(f.icon, size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        f.label,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : _C.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _C.roseSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _C.rose,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: _C.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: loadDetail,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: _C.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Retry',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
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

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.15;
    if (w > 600) return w * 0.08;
    return 16;
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
          'Stock Detail',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!isLoading && !hasError && stock.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _downloadPdf,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PDF',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: const BoxDecoration(color: _C.bg),
          ),
        ),
      ),
      body: SafeArea(
        child: hasError
            ? _errorWidget()
            : RefreshIndicator(
                color: _C.indigo,
                onRefresh: loadDetail,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hp, 0, hp, 30),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _headerCard(),
                          _filterBar(),
                          const SizedBox(height: 16),

                          if (_shouldShow(_Filter.drug))
                            _sectionCard(
                              title: 'Drug Information',
                              icon: Icons.medication_rounded,
                              iconColor: _C.purple,
                              iconBg: _C.purpleSoft,
                              children: [
                                _infoRow('Drug Name', stock['drug_name']),
                                _infoRow('Composition', stock['composition']),
                                _infoRow('Category', stock['category']),
                                _infoRow('Dosage Form', stock['dosage_form']),
                                _infoRow('Strength', stock['strength']),
                              ],
                            ),

                          if (_shouldShow(_Filter.batch))
                            _sectionCard(
                              title: 'Batch Information',
                              icon: Icons.inventory_2_rounded,
                              iconColor: _C.amber,
                              iconBg: _C.amberSoft,
                              children: [
                                _infoRow('Batch Number', stock['batch_no']),
                                _infoRow(
                                  'Manufacture Date',
                                  _formatDateTime(stock['manufacture_date']),
                                ),

                                _infoRow(
                                  'Expiry Date',
                                  _formatDateTime(stock['expiry_date']),
                                ), _infoRow('Batch Status', stock['batch_status']),
                              ],
                            ),

                          if (_shouldShow(_Filter.pricing))
                            _sectionCard(
                              title: 'Pricing Information',
                              icon: Icons.currency_rupee_rounded,
                              iconColor: _C.green,
                              iconBg: _C.greenSoft,
                              children: [
                                _infoRow(
                                  'Manufacturer Price',
                                  stock['manufacturer_price'],
                                ),
                                _infoRow(
                                  'Wholesaler Price',
                                  stock['wholesaler_price'],
                                ),
                                _infoRow(
                                  'Retailer Price',
                                  stock['retailer_price'],
                                ),
                              ],
                            ),

                          if (_shouldShow(_Filter.manufacturer))
                            _sectionCard(
                              title: 'Manufacturer Detail',
                              icon: Icons.factory_rounded,
                              iconColor: _C.blue,
                              iconBg: _C.blueSoft,
                              children: [
                                _infoRow(
                                  'Company Name',
                                  stock['manufacturer_name'],
                                ),
                                _infoRow(
                                  'Drug License',
                                  stock['manufacturer_license'],
                                ),
                                _infoRow('GSTIN', stock['manufacturer_gstin']),
                                _infoRow(
                                  'PAN Number',
                                  stock['manufacturer_pan'],
                                ),
                                _infoRow(
                                  'CIN Number',
                                  stock['manufacturer_cin'],
                                ),
                                _infoRow('Phone', stock['manufacturer_phone']),
                                _infoRow('Email', stock['manufacturer_email']),
                                _infoRow(
                                  'Website',
                                  stock['manufacturer_website'],
                                ),
                                _infoRow(
                                  'Address',
                                  stock['manufacturer_address'],
                                ),
                              ],
                            ),

                          if (!isLoading &&
                              _isWholesaler &&
                              _shouldShow(_Filter.wholesaler))
                            _sectionCard(
                              title: 'Wholesaler Detail',
                              icon: Icons.local_shipping_rounded,
                              iconColor: _C.teal,
                              iconBg: _C.tealSoft,
                              children: [
                                _infoRow(
                                  'Company Name',
                                  stock['wholesaler_name'],
                                ),
                                _infoRow(
                                  'Drug License',
                                  stock['wholesaler_license'],
                                ),
                                _infoRow('GSTIN', stock['wholesaler_gstin']),
                                _infoRow('Phone', stock['wholesaler_phone']),
                                _infoRow('Email', stock['wholesaler_email']),
                                _infoRow(
                                  'Address',
                                  stock['wholesaler_address'],
                                ),
                                _infoRow('Owner Name', stock['user_name']),
                                _infoRow('Mobile', stock['mobile']),
                              ],
                            ),

                          if (!isLoading &&
                              _isRetailer &&
                              _shouldShow(_Filter.retailer))
                            _sectionCard(
                              title: 'Retailer Detail',
                              icon: Icons.store_rounded,
                              iconColor: _C.rose,
                              iconBg: _C.roseSoft,
                              children: [
                                _infoRow(
                                  'Shop Name',
                                  stock['retailer_shop_name'],
                                ),
                                _infoRow(
                                  'Drug License',
                                  stock['retailer_license'],
                                ),
                                _infoRow('GSTIN', stock['retailer_gstin']),
                                _infoRow('Phone', stock['retailer_phone']),
                                _infoRow('Email', stock['retailer_email']),
                                _infoRow('Address', stock['retailer_address']),
                                _infoRow('Owner Name', stock['user_name']),
                                _infoRow('Mobile', stock['mobile']),
                              ],
                            ),

                          if (!isLoading &&
                              _hasSupplier &&
                              _shouldShow(_Filter.supplier))
                            _sectionCard(
                              title: 'Supplier Wholesaler',
                              icon: Icons.warehouse_rounded,
                              iconColor: const Color(0xFF92400E),
                              iconBg: const Color(0xFFFEF3C7),
                              children: [
                                _infoRow(
                                  'Company Name',
                                  stock['supplier_wholesaler']['company_name'],
                                ),
                                _infoRow(
                                  'Drug License',
                                  stock['supplier_wholesaler']['drug_license_no'],
                                ),
                                _infoRow(
                                  'GSTIN',
                                  stock['supplier_wholesaler']['gstin'],
                                ),
                                _infoRow(
                                  'Phone',
                                  stock['supplier_wholesaler']['phone'],
                                ),
                                _infoRow(
                                  'Email',
                                  stock['supplier_wholesaler']['email'],
                                ),
                                _infoRow(
                                  'Address',
                                  stock['supplier_wholesaler']['address'],
                                ),
                                _infoRow(
                                  'Owner Name',
                                  stock['supplier_wholesaler']['owner_name'],
                                ),
                                _infoRow(
                                  'Owner Mobile',
                                  stock['supplier_wholesaler']['owner_mobile'],
                                ),
                              ],
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
