import 'package:drug_tracking_system/core/services/api_service/retailer_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum SaleFilter { all, today, thisWeek, thisMonth }

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

class SaleHistoryScreen extends StatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  State<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  SaleFilter _activeFilter = SaleFilter.all;
  final TextEditingController _searchCtrl = TextEditingController();

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
    _searchCtrl.addListener(_applyFilters);
    _loadSales();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await RetailerApi.getSaleHistory();
      if (!mounted) return;
      setState(() {
        _sales = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
      _applyFilters();
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
    final query = _searchCtrl.text.toLowerCase().trim();
    final now = DateTime.now();
    List<Map<String, dynamic>> result = List.from(_sales);

    switch (_activeFilter) {
      case SaleFilter.today:
        result = result.where((e) {
          try {
            final d = DateTime.parse(e['created_at']).toLocal();
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          } catch (_) {
            return false;
          }
        }).toList();
        break;
      case SaleFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final ws = DateTime(weekStart.year, weekStart.month, weekStart.day);
        result = result.where((e) {
          try {
            final d = DateTime.parse(e['created_at']).toLocal();
            return d.isAfter(ws.subtract(const Duration(seconds: 1)));
          } catch (_) {
            return false;
          }
        }).toList();
        break;
      case SaleFilter.thisMonth:
        result = result.where((e) {
          try {
            final d = DateTime.parse(e['created_at']).toLocal();
            return d.year == now.year && d.month == now.month;
          } catch (_) {
            return false;
          }
        }).toList();
        break;
      case SaleFilter.all:
        break;
    }

    if (query.isNotEmpty) {
      result = result.where((e) {
        final patient = (e['patient_name'] ?? '').toString().toLowerCase();
        final doctor = (e['doctor_name'] ?? '').toString().toLowerCase();
        final abha = (e['abha_id'] ?? '').toString().toLowerCase();
        final mode = (e['payment_mode'] ?? '').toString().toLowerCase();
        final drugs = (e['drugs'] as List<dynamic>? ?? []).any((d) {
          return (d['drug_name'] ?? '').toString().toLowerCase().contains(
                query,
              ) ||
              (d['batch_no'] ?? '').toString().toLowerCase().contains(query);
        });
        return patient.contains(query) ||
            doctor.contains(query) ||
            abha.contains(query) ||
            mode.contains(query) ||
            drugs;
      }).toList();
    }

    setState(() => _filtered = result);
  }

  String _fmtDate(String? v) {
    if (v == null || v.trim().isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  String _fmtTime(String? v) {
    if (v == null || v.trim().isEmpty) return '';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return '';
    }
  }

  double get _totalRevenue =>
      _filtered.fold(0.0, (s, e) => s + (e['total_amount'] as num).toDouble());

  Future<void> _downloadAllPdf() async {
    final doc = pw.Document();

    for (final sale in _filtered) {
      final drugs = (sale['drugs'] as List<dynamic>? ?? []);
      final createdAt = sale['created_at']?.toString() ?? '';
      final dateStr = _fmtDate(createdAt);
      final timeStr = _fmtTime(createdAt);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
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
                        'Sale Receipt',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '$dateStr  $timeStr',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFE2E8F0),
                    ),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Patient Information',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF0F172A),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _pdfRow('Patient Name', sale['patient_name'] ?? ''),
                      _pdfRow('Mobile', sale['patient_mobile'] ?? ''),
                      _pdfRow('ABHA ID', sale['abha_id'] ?? ''),
                      _pdfRow('Doctor', sale['doctor_name'] ?? ''),
                      _pdfRow('Payment Mode', sale['payment_mode'] ?? ''),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'Medicines Sold',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF0F172A),
                  ),
                ),
                pw.SizedBox(height: 8),
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
                    4: const pw.FlexColumnWidth(1.5),
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
                        _pdfTh('Price'),
                        _pdfTh('Total'),
                      ],
                    ),
                    ...drugs.map((d) {
                      return pw.TableRow(
                        children: [
                          _pdfTd(d['drug_name'] ?? ''),
                          _pdfTd(d['batch_no'] ?? ''),
                          _pdfTd(d['quantity'].toString()),
                          _pdfTd('₹${(d['price'] as num).toStringAsFixed(2)}'),
                          _pdfTd(
                            '₹${(d['total_amount'] as num).toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFDCFCE7),
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFF16A34A),
                        width: 0.5,
                      ),
                    ),
                    child: pw.Text(
                      'Grand Total: ₹${(sale['total_amount'] as num).toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (fmt) async => doc.save(),
      name: 'sale_history_all.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromInt(0xFF64748B),
              ),
            ),
          ),
          pw.Text(
            ': $value',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF0F172A),
            ),
          ),
        ],
      ),
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

  Widget _summaryCard(
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

  Widget _summarySkeletonCard() {
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
    final totalSales = _filtered.length;
    final totalRevenue = _totalRevenue;

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
            children: _isLoading
                ? List.generate(
                    2,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 1 ? 10 : 0),
                        child: _summarySkeletonCard(),
                      ),
                    ),
                  )
                : [
                    Expanded(
                      child: _summaryCard(
                        'Total Sales',
                        '$totalSales',
                        Icons.receipt_long_rounded,
                        _C.indigo,
                        _C.indigoSoft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        'Revenue',
                        '₹${totalRevenue.toStringAsFixed(0)}',
                        Icons.account_balance_wallet_rounded,
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
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search drug, patient, doctor...',
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
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
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
      ('All', SaleFilter.all, Icons.apps_rounded, _C.indigo, _C.indigoSoft),
      ('Today', SaleFilter.today, Icons.today_rounded, _C.blue, _C.blueSoft),
      (
        'This Week',
        SaleFilter.thisWeek,
        Icons.date_range_rounded,
        _C.green,
        _C.greenSoft,
      ),
      (
        'This Month',
        SaleFilter.thisMonth,
        Icons.calendar_month_rounded,
        _C.amber,
        _C.amberSoft,
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

  Widget _shimmerSaleCard() {
    final hp = _hPad;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                _ShimmerBox(width: 52, height: 52, radius: 26),
                SizedBox(width: 14),
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
                SizedBox(width: 12),
                Column(
                  children: [
                    _ShimmerBox(width: 60, height: 18),
                    SizedBox(height: 6),
                    _ShimmerBox(width: 40, height: 11),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            _ShimmerBox(width: double.infinity, height: 68, radius: 14),
            SizedBox(height: 10),
            _ShimmerBox(width: double.infinity, height: 72, radius: 16),
            SizedBox(height: 10),
            _ShimmerBox(width: double.infinity, height: 36, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
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

  Widget _miniChip(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.nunito(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saleCard(Map<String, dynamic> sale) {
    final hp = _hPad;
    final drugs = (sale['drugs'] as List<dynamic>? ?? []);
    final double total = (sale['total_amount'] as num).toDouble();
    final String patient = sale['patient_name'] ?? '';
    final String mobile = sale['patient_mobile'] ?? '';
    final String doctor = sale['doctor_name'] ?? '';
    final String abha = sale['abha_id'] ?? '';
    final String payMode = sale['payment_mode'] ?? '';
    final String createdAt = sale['created_at'] ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, 12),
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: _fadeAnim,
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
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.isNotEmpty ? patient : 'Unknown Patient',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            if (mobile.isNotEmpty)
                              Text(
                                mobile,
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _fmtDate(createdAt),
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _fmtTime(createdAt),
                            style: GoogleFonts.nunito(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (doctor.isNotEmpty ||
                          abha.isNotEmpty ||
                          payMode.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _C.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _C.divider),
                          ),
                          child: Column(
                            children: [
                              if (doctor.isNotEmpty)
                                _detailRow(
                                  Icons.local_hospital_rounded,
                                  'Doctor',
                                  doctor,
                                  _C.indigo,
                                ),
                              if (abha.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                _detailRow(
                                  Icons.badge_rounded,
                                  'ABHA ID',
                                  abha,
                                  _C.blue,
                                ),
                              ],
                              if (payMode.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                _detailRow(
                                  Icons.payment_rounded,
                                  'Payment',
                                  payMode,
                                  _C.green,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
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
                            'Medicines',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
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
                              color: _C.indigoSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${drugs.length}',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _C.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...drugs.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value as Map<String, dynamic>;
                        final dTotal = (d['total_amount'] as num).toDouble();
                        final dQty = d['quantity'] as int? ?? 0;
                        final dPrice = (d['price'] as num).toDouble();
                        final dName = d['drug_name'] ?? '';
                        final dBatch = d['batch_no'] ?? '';
                        final dStrength = d['strength'] ?? '';
                        final dForm = d['dosage_form'] ?? '';

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i < drugs.length - 1 ? 10 : 0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _C.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _C.divider),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.indigoSoft.withValues(alpha: 0.5),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _C.indigo.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.medication_rounded,
                                          color: _C.indigo,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.nunito(
                                                color: _C.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            if (dStrength.isNotEmpty ||
                                                dForm.isNotEmpty)
                                              Text(
                                                [dStrength, dForm]
                                                    .where((s) => s.isNotEmpty)
                                                    .join(' • '),
                                                style: GoogleFonts.nunito(
                                                  color: _C.indigo,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _C.indigoSoft,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          dBatch,
                                          style: GoogleFonts.nunito(
                                            color: _C.indigo,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    8,
                                    14,
                                    10,
                                  ),
                                  child: Row(
                                    children: [
                                      _miniChip(
                                        'Qty',
                                        dQty.toString(),
                                        _C.blue,
                                        _C.blueSoft,
                                      ),
                                      const SizedBox(width: 8),
                                      _miniChip(
                                        'Price',
                                        '₹${dPrice.toStringAsFixed(2)}',
                                        _C.amber,
                                        _C.amberSoft,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${dTotal.toStringAsFixed(2)}',
                                        style: GoogleFonts.nunito(
                                          color: _C.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _C.greenSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _C.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              size: 16,
                              color: _C.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Grand Total',
                              style: GoogleFonts.nunito(
                                color: _C.textSub,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: GoogleFonts.nunito(
                                color: _C.green,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              Icons.receipt_long_outlined,
              size: 38,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Sales Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _activeFilter != SaleFilter.all
                ? 'No sales in this period'
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

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Sale History',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isLoading && _filtered.isNotEmpty)
            GestureDetector(
              onTap: _downloadAllPdf,
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
            onRefresh: _loadSales,
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
                              'Sales List',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!_isLoading)
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
                                  '${_filtered.length}',
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
                if (_isLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _shimmerSaleCard(),
                      childCount: 4,
                    ),
                  )
                else if (_filtered.isEmpty)
                  SliverToBoxAdapter(child: _emptyWidget())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _saleCard(_filtered[i]),
                      childCount: _filtered.length,
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
