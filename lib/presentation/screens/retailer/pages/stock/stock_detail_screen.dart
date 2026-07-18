import 'package:flutter/material.dart';
import 'package:drug_tracking_system/core/services/api_service/retailer_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  static const orange = Color(0xFFFF7043);
  static const orangeSoft = Color(0xFFFFF3EE);
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

class StockDetailScreen extends StatefulWidget {
  final int batchId;

  const StockDetailScreen({super.key, required this.batchId});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? stock;
  bool isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Map<String, bool> _expanded = {
    'drug': true,
    'batch': true,
    'manufacturer': false,
    'wholesaler': false,
  };

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
    loadStockDetail();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String formatDateTime(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(date.toString()).toLocal());
    } catch (_) {
      return date.toString();
    }
  }

  String formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(date.toString()).toLocal());
    } catch (_) {
      return date.toString();
    }
  }

  String val(String key) => stock?[key]?.toString() ?? '';

  Future<void> loadStockDetail() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await RetailerApi.getStockDetail(widget.batchId);
      if (!mounted) return;
      setState(() {
        stock = data;
        isLoading = false;
      });
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

  Future<void> _downloadPdf() async {
    if (stock == null) return;
    final doc = pw.Document();

    void addSection(pw.Document d, String title, List<List<String>> rows) {
      if (rows.isEmpty) return;
    }

    final sections = <Map<String, dynamic>>[
      {
        'title': 'Drug Information',
        'rows': [
          if (val('drug_name').isNotEmpty) ['Drug Name', val('drug_name')],
          if (val('batch_no').isNotEmpty) ['Batch No', val('batch_no')],
          if (val('category').isNotEmpty) ['Category', val('category')],
          if (val('dosage_form').isNotEmpty)
            ['Dosage Form', val('dosage_form')],
          if (val('strength').isNotEmpty) ['Strength', val('strength')],
          if (val('composition').isNotEmpty)
            ['Composition', val('composition')],
        ],
      },
      {
        'title': 'Batch Information',
        'rows': [
          if (val('batch_no').isNotEmpty) ['Batch No', val('batch_no')],
          ['Manufactured', formatDate(stock!['manufacture_date'])],
          ['Expiry', formatDate(stock!['expiry_date'])],
          ['Stock Receive Date', formatDate(stock!['stock_receive_date'])],
          if (val('batch_status').isNotEmpty)
            ['Batch Status', val('batch_status')],
          ['Accepted At', formatDateTime(stock!['accepted_at'])],
          if (val('invoice_number').isNotEmpty)
            ['Invoice No', val('invoice_number')],
        ],
      },
      {
        'title': 'Pricing',
        'rows': [
          if (val('mrp').isNotEmpty && val('mrp') != '0')
            ['MRP', 'Rs.${val('mrp')}'],
          if (val('retailer_purchase_price').isNotEmpty &&
              val('retailer_purchase_price') != '0')
            ['Purchase Price', 'Rs.${val('retailer_purchase_price')}'],
        ],
      },
      {
        'title': 'Manufacturer',
        'rows': [
          if (val('manufacturer_name').isNotEmpty)
            ['Company', val('manufacturer_name')],
          if (val('gstin').isNotEmpty) ['GSTIN', val('gstin')],
          if (val('drug_license_no').isNotEmpty)
            ['Drug License', val('drug_license_no')],
          if (val('pan_no').isNotEmpty) ['PAN', val('pan_no')],
          if (val('cin_no').isNotEmpty) ['CIN', val('cin_no')],
          if (val('manufacturer_phone').isNotEmpty)
            ['Phone', val('manufacturer_phone')],
          if (val('manufacturer_email').isNotEmpty)
            ['Email', val('manufacturer_email')],
          if (val('manufacturer_website').isNotEmpty)
            ['Website', val('manufacturer_website')],
          if (val('manufacturer_address').isNotEmpty)
            ['Address', val('manufacturer_address')],
        ],
      },
      {
        'title': 'Wholesaler',
        'rows': [
          if (val('wholesaler_name').isNotEmpty)
            ['Company', val('wholesaler_name')],
          if (val('wholesaler_gstin').isNotEmpty)
            ['GSTIN', val('wholesaler_gstin')],
          if (val('wholesaler_drug_license_no').isNotEmpty)
            ['Drug License', val('wholesaler_drug_license_no')],
          if (val('wholesaler_phone').isNotEmpty)
            ['Phone', val('wholesaler_phone')],
          if (val('wholesaler_email').isNotEmpty)
            ['Email', val('wholesaler_email')],
        ],
      },
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) {
          final int qty = stock?['quantity'] as int? ?? 0;
          final bool low = qty < 20;

          return [
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
                    'Stock Detail Report',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${val('drug_name')}  •  Batch: ${val('batch_no')}',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Qty: $qty  |  Status: ${low ? 'LOW STOCK' : 'IN STOCK'}',
                    style: pw.TextStyle(
                      color: low
                          ? const PdfColor.fromInt(0xFFBE123C)
                          : const PdfColor.fromInt(0xFF16A34A),
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            ...sections.map((section) {
              final rows = (section['rows'] as List).cast<List<String>>();
              if (rows.isEmpty) return pw.SizedBox();
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFEEF2FF),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      section['title'] as String,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF4338CA),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: const PdfColor.fromInt(0xFFE2E8F0),
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(4),
                    },
                    children: rows.map((row) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: pw.Text(
                              row[0],
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColor.fromInt(0xFF64748B),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: pw.Text(
                              row[1],
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  pw.SizedBox(height: 14),
                ],
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (fmt) async => doc.save(),
      name:
          'stock_detail_${val('drug_name').replaceAll(' ', '_')}_${val('batch_no')}.pdf',
    );
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16;
  }

  Widget _row(IconData icon, String label, String value, {Color? iconColor}) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor ?? _C.indigo),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                color: _C.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                color: _C.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String sectionKey,
    required String title,
    required IconData titleIcon,
    required Color accentColor,
    required Color accentBg,
    required List<Widget> children,
  }) {
    final hasContent = children.any((w) => w is Padding);
    if (!hasContent) return const SizedBox.shrink();

    final bool isOpen = _expanded[sectionKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? accentColor.withValues(alpha: 0.2) : _C.divider,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: isOpen
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : BorderRadius.circular(20),
            onTap: () => setState(() => _expanded[sectionKey] = !isOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isOpen ? accentBg : _C.surface,
                borderRadius: isOpen
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isOpen ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(titleIcon, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isOpen ? _C.textPrimary : _C.textSub,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeOut,
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(children: children),
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    final int qty = stock?['quantity'] as int? ?? 0;
    final bool low = qty < 20;
    final Color accent = low ? _C.rose : _C.green;
    final Color accentBg = low ? _C.roseSoft : _C.greenSoft;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.indigo.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            val('drug_name').isNotEmpty
                                ? val('drug_name')
                                : 'Unknown Drug',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Batch: ${val('batch_no')}',
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentBg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Qty: $qty',
                            style: GoogleFonts.nunito(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              low ? 'LOW' : 'IN STOCK',
                              style: GoogleFonts.nunito(
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (stock?['is_narcotic'] == 1 ||
                        stock?['is_narcotic'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _C.roseSoft,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              size: 13,
                              color: _C.rose,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Narcotic',
                              style: GoogleFonts.nunito(
                                color: _C.rose,
                                fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _quickStats() {
    final mrp = val('mrp');
    final purchasePrice = val('retailer_purchase_price');
    final invoiceNo = val('invoice_number');

    final pills = <Map<String, dynamic>>[
      if (mrp.isNotEmpty && mrp != '0')
        {
          'label': 'MRP',
          'value': '₹$mrp',
          'color': _C.indigo,
          'bg': _C.indigoSoft,
        },
      if (purchasePrice.isNotEmpty && purchasePrice != '0')
        {
          'label': 'Purchase',
          'value': '₹$purchasePrice',
          'color': _C.green,
          'bg': _C.greenSoft,
        },
      if (invoiceNo.isNotEmpty)
        {
          'label': 'Invoice',
          'value': invoiceNo,
          'color': _C.blue,
          'bg': _C.blueSoft,
        },
    ];

    if (pills.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          for (int i = 0; i < pills.length; i++) ...[
            Expanded(
              child: _statPill(
                pills[i]['label'] as String,
                pills[i]['value'] as String,
                pills[i]['color'] as Color,
                pills[i]['bg'] as Color,
              ),
            ),
            if (i < pills.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              color: _C.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandCollapseAll() {
    final allOpen = _expanded.values.every((v) => v);
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => setState(() {
          for (final k in _expanded.keys) {
            _expanded[k] = !allOpen;
          }
        }),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _C.indigoSoft,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _C.indigo.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allOpen ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                size: 15,
                color: _C.indigo,
              ),
              const SizedBox(width: 6),
              Text(
                allOpen ? 'Collapse All' : 'Expand All',
                style: GoogleFonts.nunito(
                  color: _C.indigo,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBody(double hp) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hp, 20, hp, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  _C.indigo.withValues(alpha: 0.15),
                  _C.purple.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      _ShimmerBox(width: 56, height: 56, radius: 16),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBox(width: 180, height: 18),
                            SizedBox(height: 8),
                            _ShimmerBox(width: 120, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _ShimmerBox(width: 120, height: 34, radius: 30),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _ShimmerBox(height: 56, radius: 14)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBox(height: 56, radius: 14)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBox(height: 56, radius: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: _ShimmerBox(width: 110, height: 32, radius: 30),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          _ShimmerBox(width: 36, height: 36, radius: 11),
                          SizedBox(width: 12),
                          Expanded(child: _ShimmerBox(height: 14)),
                          SizedBox(width: 40),
                          _ShimmerBox(width: 28, height: 28, radius: 8),
                        ],
                      ),
                      if (i < 2) ...[
                        const SizedBox(height: 14),
                        const _ShimmerBox(height: 11),
                        const SizedBox(height: 8),
                        const _ShimmerBox(width: 200, height: 11),
                        const SizedBox(height: 8),
                        const _ShimmerBox(width: 160, height: 11),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget(double hp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 60, hp, 0),
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
            'No Details Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull down to refresh',
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Stock Details',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!isLoading && stock != null)
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
      body: SafeArea(
        child: isLoading
            ? _shimmerBody(hp)
            : stock == null
            ? RefreshIndicator(
                color: _C.indigo,
                onRefresh: loadStockDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _emptyWidget(hp),
                  ),
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  color: _C.indigo,
                  onRefresh: loadStockDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(hp, 20, hp, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroCard(),
                        _quickStats(),
                        _expandCollapseAll(),
                        _section(
                          sectionKey: 'drug',
                          title: 'Drug Information',
                          titleIcon: Icons.science_rounded,
                          accentColor: _C.indigo,
                          accentBg: _C.indigoSoft,
                          children: [
                            _row(
                              Icons.category_rounded,
                              'Category',
                              val('category'),
                            ),
                            _row(
                              Icons.medication_liquid_outlined,
                              'Dosage Form',
                              val('dosage_form'),
                            ),
                            _row(
                              Icons.fitness_center_outlined,
                              'Strength',
                              val('strength'),
                            ),
                            _row(
                              Icons.biotech_outlined,
                              'Composition',
                              val('composition'),
                            ),
                          ],
                        ),
                        _section(
                          sectionKey: 'batch',
                          title: 'Batch Information',
                          titleIcon: Icons.qr_code_2_rounded,
                          accentColor: _C.blue,
                          accentBg: _C.blueSoft,
                          children: [
                            _row(
                              Icons.tag_rounded,
                              'Batch No',
                              val('batch_no'),
                              iconColor: _C.blue,
                            ),
                            _row(
                              Icons.factory_rounded,
                              'Manufactured',
                              formatDate(stock!['manufacture_date']),
                              iconColor: _C.blue,
                            ),
                            _row(
                              Icons.event_busy_rounded,
                              'Expiry',
                              formatDate(stock!['expiry_date']),
                              iconColor: _C.blue,
                            ),
                            _row(
                              Icons.local_shipping_outlined,
                              'Stock Receive Date',
                              formatDate(stock!['stock_receive_date']),
                              iconColor: _C.blue,
                            ),
                            _row(
                              Icons.verified_rounded,
                              'Batch Status',
                              val('batch_status'),
                              iconColor: _C.blue,
                            ),
                            _row(
                              Icons.check_circle_outline_rounded,
                              'Accepted At',
                              formatDateTime(stock!['accepted_at']),
                              iconColor: _C.blue,
                            ),
                          ],
                        ),
                        _section(
                          sectionKey: 'manufacturer',
                          title: 'Manufacturer',
                          titleIcon: Icons.business_rounded,
                          accentColor: _C.orange,
                          accentBg: _C.orangeSoft,
                          children: [
                            _row(
                              Icons.business_outlined,
                              'Company',
                              val('manufacturer_name'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.badge_outlined,
                              'GSTIN',
                              val('gstin'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.verified_outlined,
                              'Drug License',
                              val('drug_license_no'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.credit_card_outlined,
                              'PAN',
                              val('pan_no'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.apartment_outlined,
                              'CIN',
                              val('cin_no'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.phone_outlined,
                              'Phone',
                              val('manufacturer_phone'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.email_outlined,
                              'Email',
                              val('manufacturer_email'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.language_outlined,
                              'Website',
                              val('manufacturer_website'),
                              iconColor: _C.orange,
                            ),
                            _row(
                              Icons.location_on_outlined,
                              'Address',
                              val('manufacturer_address'),
                              iconColor: _C.orange,
                            ),
                          ],
                        ),
                        _section(
                          sectionKey: 'wholesaler',
                          title: 'Wholesaler',
                          titleIcon: Icons.store_rounded,
                          accentColor: _C.green,
                          accentBg: _C.greenSoft,
                          children: [
                            _row(
                              Icons.store_outlined,
                              'Company',
                              val('wholesaler_name'),
                              iconColor: _C.green,
                            ),
                            _row(
                              Icons.badge_outlined,
                              'GSTIN',
                              val('wholesaler_gstin'),
                              iconColor: _C.green,
                            ),
                            _row(
                              Icons.verified_outlined,
                              'Drug License',
                              val('wholesaler_drug_license_no'),
                              iconColor: _C.green,
                            ),
                            _row(
                              Icons.phone_outlined,
                              'Phone',
                              val('wholesaler_phone'),
                              iconColor: _C.green,
                            ),
                            _row(
                              Icons.email_outlined,
                              'Email',
                              val('wholesaler_email'),
                              iconColor: _C.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
