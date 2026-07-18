import 'package:flutter/material.dart';
import 'package:drug_tracking_system/core/services/api_service/retailer_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stock_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum StockFilter { all, lowStock, inStock }

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

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> stock = [];
  List<Map<String, dynamic>> filteredStock = [];

  bool isLoading = true;
  StockFilter _activeFilter = StockFilter.all;

  final TextEditingController searchController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    searchController.addListener(_applyFilters);
    loadStock();
  }

  @override
  void dispose() {
    searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _fmtDateOnly(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  Future<void> loadStock() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await RetailerApi.getStock();
      if (!mounted) return;
      final parsed = data.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          'batch_id': int.tryParse(m['batch_id']?.toString() ?? '') ?? 0,
          'drug_name': m['drug_name']?.toString() ?? '',
          'batch_no': m['batch_no']?.toString() ?? '',
          'quantity': int.tryParse(m['quantity']?.toString() ?? '') ?? 0,
          'manufacturer_name': m['manufacturer_name']?.toString() ?? '',
          'mrp': double.tryParse(m['mrp']?.toString() ?? '0') ?? 0,
          'manufacture_date': m['manufacture_date']?.toString() ?? '',
          'expiry_date': m['expiry_date']?.toString() ?? '',
          'accepted_at': m['accepted_at']?.toString() ?? '',
        };
      }).toList();
      setState(() {
        stock = parsed;
        isLoading = false;
      });
      _applyFilters();
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: _C.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    final query = searchController.text.toLowerCase().trim();
    List<Map<String, dynamic>> result = List.from(stock);

    if (_activeFilter == StockFilter.lowStock) {
      result = result.where((e) => (e['quantity'] as int) < 20).toList();
    } else if (_activeFilter == StockFilter.inStock) {
      result = result.where((e) => (e['quantity'] as int) >= 20).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((item) {
        return item['drug_name'].toString().toLowerCase().contains(query) ||
            item['batch_no'].toString().toLowerCase().contains(query);
      }).toList();
    }

    setState(() => filteredStock = result);
  }

  int get totalItems => stock.length;
  int get lowStockCount =>
      stock.where((e) => (e['quantity'] as int) < 20).length;
  int get inStockCount =>
      stock.where((e) => (e['quantity'] as int) >= 20).length;

  Future<void> _downloadPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF4338CA),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Stock Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Text(
                      'Total: ${stock.length}   Low Stock: $lowStockCount   In Stock: $inStockCount',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFFE2E8F0),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(2),
              5: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF4338CA),
                ),
                children: [
                  _pdfTh('Drug Name'),
                  _pdfTh('Batch No'),
                  _pdfTh('Qty'),
                  _pdfTh('MRP'),
                  _pdfTh('Expiry'),
                  _pdfTh('Status'),
                ],
              ),
              ...filteredStock.map((item) {
                final int qty = item['quantity'] as int;
                final bool low = qty < 20;
                return pw.TableRow(
                  children: [
                    _pdfTd(item['drug_name'] ?? ''),
                    _pdfTd(item['batch_no'] ?? ''),
                    _pdfTd(qty.toString()),
                    _pdfTd('Rs.${item['mrp']}'),
                    _pdfTd(_fmtDateOnly(item['expiry_date'])),
                    _pdfTdColored(low ? 'LOW' : 'IN STOCK', low),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (fmt) async => doc.save(),
      name: 'stock_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _pdfTh(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _pdfTd(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColor.fromInt(0xFF0F172A),
        ),
      ),
    );
  }

  pw.Widget _pdfTdColored(String text, bool low) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: low
              ? const PdfColor.fromInt(0xFFBE123C)
              : const PdfColor.fromInt(0xFF16A34A),
        ),
      ),
    );
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
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: isLoading
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
                        '$totalItems',
                        Icons.inventory_2_rounded,
                        _C.indigo,
                        _C.indigoSoft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _overviewCard(
                        'Low Stock',
                        '$lowStockCount',
                        Icons.warning_amber_rounded,
                        _C.rose,
                        _C.roseSoft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _overviewCard(
                        'In Stock',
                        '$inStockCount',
                        Icons.check_circle_rounded,
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
              controller: searchController,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search drug or batch...',
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
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchController.clear();
                          _applyFilters();
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

  Widget _filterChips() {
    final hp = _hPad;
    final filters = [
      ('All', StockFilter.all, Icons.apps_rounded, _C.indigo, _C.indigoSoft),
      (
        'Low Stock',
        StockFilter.lowStock,
        Icons.warning_amber_rounded,
        _C.rose,
        _C.roseSoft,
      ),
      (
        'In Stock',
        StockFilter.inStock,
        Icons.check_circle_outline_rounded,
        _C.green,
        _C.greenSoft,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            final selected = _activeFilter == f.$2;
            return Padding(
              padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeFilter = f.$2);
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? f.$5 : _C.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected
                          ? f.$4.withValues(alpha: 0.4)
                          : _C.divider,
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _C.shadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(f.$3, size: 13, color: selected ? f.$4 : _C.textSub),
                      const SizedBox(width: 6),
                      Text(
                        f.$1,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? f.$4 : _C.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _shimmerStockCard() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 12),
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: const [
                  _ShimmerBox(width: 48, height: 48, radius: 14),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(width: 140, height: 14),
                        SizedBox(height: 8),
                        _ShimmerBox(width: 100, height: 11),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ShimmerBox(width: 36, height: 24),
                      SizedBox(height: 6),
                      _ShimmerBox(width: 52, height: 18),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerBox(width: double.infinity, height: 11),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 160, height: 11),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 200, height: 11),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 180, height: 11),
                  SizedBox(height: 12),
                  _ShimmerBox(width: 90, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: _C.indigo),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.nunito(
            color: _C.textSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              color: _C.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stockCard(Map<String, dynamic> item) {
    final hp = _hPad;
    final int qty = item['quantity'] as int;
    final int batchId = item['batch_id'] as int;
    final bool lowStock = qty < 20;
    final Color accent = lowStock ? _C.rose : _C.green;
    final Color accentBg = lowStock ? _C.roseSoft : _C.greenSoft;
    final String badgeLabel = lowStock ? 'LOW' : 'IN STOCK';
    final IconData badgeIcon = lowStock
        ? Icons.warning_amber_rounded
        : Icons.check_circle_rounded;

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 12),
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StockDetailScreen(batchId: batchId),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: lowStock ? _C.rose.withValues(alpha: 0.4) : _C.divider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accentBg.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['drug_name'].toString().isNotEmpty
                                    ? item['drug_name']
                                    : 'Unknown Drug',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  color: _C.textPrimary,
                                  fontSize: 15,
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
                                    'Batch: ${item['batch_no']}',
                                    style: GoogleFonts.nunito(
                                      color: _C.textSub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              qty.toString(),
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                color: accent,
                                fontSize: 24,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(badgeIcon, size: 10, color: accent),
                                  const SizedBox(width: 3),
                                  Text(
                                    badgeLabel,
                                    style: GoogleFonts.nunito(
                                      color: accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['manufacturer_name'].toString().isNotEmpty)
                          _detailRow(
                            Icons.business_rounded,
                            'Manufacturer',
                            item['manufacturer_name'],
                          ),
                        if ((item['mrp'] ?? 0) > 0) ...[
                          const SizedBox(height: 8),
                          _detailRow(
                            Icons.currency_rupee_rounded,
                            'MRP',
                            '₹${item['mrp']}',
                          ),
                        ],
                        if (item['manufacture_date'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailRow(
                            Icons.factory_rounded,
                            'Manufacture',
                            formatDateTime(item['manufacture_date']),
                          ),
                        ],
                        if (item['expiry_date'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailRow(
                            Icons.event_busy_rounded,
                            'Expiry',
                            formatDateTime(item['expiry_date']),
                          ),
                        ],
                        if (item['accepted_at'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailRow(
                            Icons.verified_rounded,
                            'Accepted',
                            formatDateTime(item['accepted_at']),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'View Details',
                              style: GoogleFonts.nunito(
                                color: _C.indigo,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _C.indigoSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: _C.indigo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 40, hp, 0),
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
              Icons.inventory_2_outlined,
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
            _activeFilter == StockFilter.lowStock
                ? 'No low-stock items right now 🎉'
                : _activeFilter == StockFilter.inStock
                ? 'No in-stock items found'
                : 'Try a different search',
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
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
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
          'My Stock',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!isLoading && filteredStock.isNotEmpty)
            GestureDetector(
              onTap: _downloadPdf,
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PDF',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
            onRefresh: loadStock,
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
                      const SizedBox(height: 14),
                      _searchField(),
                      const SizedBox(height: 14),
                      _filterChips(),
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
                            if (!isLoading)
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
                                  '${filteredStock.length}',
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
                if (isLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _shimmerStockCard(),
                      childCount: 5,
                    ),
                  )
                else if (filteredStock.isEmpty)
                  SliverToBoxAdapter(child: _emptyWidget())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _stockCard(filteredStock[i]),
                      childCount: filteredStock.length,
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
