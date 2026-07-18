import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../controller/sale_details_controller.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFEF3C7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class SaleDetailsScreen extends StatelessWidget {
  final int userId;
  final String type;
  final String title;
  const SaleDetailsScreen({
    super.key,
    required this.userId,
    required this.type,
    required this.title,
  });
  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.10;
    return 16;
  }

  Future<void> _downloadPdf(
    BuildContext context,
    SaleDetailsController c,
  ) async {
    final pdf = pw.Document();
    final groups = c.groupedSales;
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            pw.Text(
              c.isRetailer ? 'Patient Sales Report' : 'Retailer Sales Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Name: ${c.name}'),
            pw.Text(
              c.isRetailer
                  ? 'Shop: ${c.shopName}'
                  : 'Company: ${c.companyName}',
            ),
            pw.Text('DL No: ${c.dlNo}'),
            pw.SizedBox(height: 16),
            ...groups.map((group) {
              final header = group['header'] as Map<String, dynamic>;
              final items = group['items'] as List<Map<String, dynamic>>;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (c.isRetailer) ...[
                      pw.Text(
                        header['patient_name']?.toString() ?? '-',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Mobile: ${header['patient_mobile'] ?? '-'}'),
                      pw.Text('Doctor: ${header['doctor_name'] ?? '-'}'),
                    ] else ...[
                      pw.Text(
                        header['retailer_name']?.toString() ?? '-',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(header['shop_name']?.toString() ?? '-'),
                      pw.Text('DL No: ${header['drug_license_no'] ?? '-'}'),
                    ],
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            'Drug',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            c.isRetailer ? 'Date' : 'Invoice Date',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    ...items.map(
                      (item) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 3),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                item['drug_name']?.toString() ?? '-',
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                item['quantity']?.toString() ?? '0',
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                c.isRetailer
                                    ? c.formatDate(item['created_at'])
                                    : c.formatInvoiceDate(item['invoice_date']),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: '${c.name}_sales_report.pdf',
    );
  }

  Widget _sectionLabel(String text) {
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
        ],
      ),
    );
  }

  Widget _profileCard(SaleDetailsController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _C.indigo,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  c.isRetailer ? c.shopName : c.companyName,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: _C.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'DL: ${c.dlNo}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: _C.indigo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (c.mobile != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    'Mobile: ${c.mobile}',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: _C.textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.isRetailer ? _C.greenSoft : _C.blueSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              c.isRetailer ? 'RETAILER' : 'WHOLESALER',
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: c.isRetailer ? _C.green : _C.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(SaleDetailsController c) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        onChanged: c.setSearch,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: c.isRetailer
              ? 'Search patient, doctor...'
              : 'Search retailer, shop, DL...',
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
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _filterChips(SaleDetailsController c) {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
      {'key': 'today', 'label': 'Today', 'icon': Icons.today_rounded},
      {'key': 'week', 'label': 'This Week', 'icon': Icons.date_range_rounded},
      {
        'key': 'month',
        'label': 'This Month',
        'icon': Icons.calendar_month_rounded,
      },
    ];
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final key = f['key'] as String;
            final label = f['label'] as String;
            final icon = f['icon'] as IconData;
            final selected = c.selectedFilter.value == key;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => c.setFilter(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _C.indigo : _C.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? _C.indigo : _C.divider,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? _C.indigo.withOpacity(0.18)
                            : _C.shadow,
                        blurRadius: selected ? 10 : 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: selected ? Colors.white : _C.indigo,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : _C.textPrimary,
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

  Widget _groupCard(Map<String, dynamic> group, SaleDetailsController c) {
    final header = group['header'] as Map<String, dynamic>;
    final items = group['items'] as List<Map<String, dynamic>>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.isRetailer ? _C.indigoSoft : _C.blueSoft,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.isRetailer ? _C.indigo : _C.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    c.isRetailer ? Icons.person_rounded : Icons.store_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.isRetailer
                            ? (header['patient_name']?.toString() ?? '-')
                            : (header['retailer_name']?.toString() ?? '-'),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (c.isRetailer) ...[
                        Text(
                          'Doctor: ${header['doctor_name'] ?? '-'}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Mobile: ${header['patient_mobile'] ?? '-'}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          header['shop_name']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'DL: ${header['drug_license_no'] ?? '-'}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: c.isRetailer ? _C.indigo : _C.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: c.isRetailer ? _C.indigo : _C.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length} items',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Drug',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _C.textSub,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _C.textSub,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    c.isRetailer ? 'Date' : 'Invoice Date',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _C.textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _C.divider),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 7),
                                decoration: BoxDecoration(
                                  color: c.isRetailer ? _C.indigo : _C.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item['drug_name']?.toString() ?? '-',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _C.greenSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['quantity']?.toString() ?? '0',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.green,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            c.isRetailer
                                ? c.formatDate(item['created_at'])
                                : c.formatInvoiceDate(item['invoice_date']),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.textSub,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(height: 1, color: _C.divider),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(SaleDetailsController c) {
    return Obx(() {
      if (c.isLoading.value && c.sales.isEmpty) {
        return Column(
          children: List.generate(3, (_) => const _SkeletonGroupCard()),
        );
      }
      if (c.errorMessage.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _C.rose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: _C.rose,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load details',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  c.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: _C.rose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: c.refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: Text(
                  'Retry',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      final groups = c.groupedSales;
      if (groups.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.divider),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _C.indigoSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 30,
                  color: _C.indigo,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No Sales Found',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try a different filter or search',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: _C.textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return Column(children: groups.map((g) => _groupCard(g, c)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SaleDetailsController(userId: userId, type: type),
      tag: '$type-$userId',
    );
    final hPad = _hPad(context);
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Sales Details',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed:
                  (controller.isLoading.value || controller.sales.isEmpty)
                  ? null
                  : () => _downloadPdf(context, controller),
              icon: Icon(
                Icons.picture_as_pdf_rounded,
                color: (controller.isLoading.value || controller.sales.isEmpty)
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white,
              ),
              tooltip: 'Download PDF',
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
        child: RefreshIndicator(
          color: _C.indigo,
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('Profile'),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.profile.isEmpty) {
                        return const _SkeletonProfileCard();
                      }
                      return _profileCard(controller);
                    }),
                    const SizedBox(height: 20),
                    _sectionLabel(
                      controller.isRetailer
                          ? 'Search Patient'
                          : 'Search Retailer',
                    ),
                    _searchField(controller),
                    const SizedBox(height: 16),
                    _sectionLabel('Filter by Date'),
                    _filterChips(controller),
                    const SizedBox(height: 16),
                    _sectionLabel(
                      controller.isRetailer
                          ? 'Patient Sales'
                          : 'Sales to Retailers',
                    ),
                    _buildSalesList(controller),
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

class _SkeletonProfileCard extends StatefulWidget {
  const _SkeletonProfileCard();
  @override
  State<_SkeletonProfileCard> createState() => _SkeletonProfileCardState();
}

class _SkeletonProfileCardState extends State<_SkeletonProfileCard>
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

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _C.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_anim),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _shimmerBox(width: 52, height: 52, radius: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 140, height: 16),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 100, height: 12),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 120, height: 11),
                ],
              ),
            ),
            _shimmerBox(width: 80, height: 20, radius: 10),
          ],
        ),
      ),
    );
  }
}

class _SkeletonGroupCard extends StatefulWidget {
  const _SkeletonGroupCard();
  @override
  State<_SkeletonGroupCard> createState() => _SkeletonGroupCardState();
}

class _SkeletonGroupCardState extends State<_SkeletonGroupCard>
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

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _C.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_anim),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  _shimmerBox(width: 40, height: 40, radius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 120, height: 14),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 90, height: 10),
                      ],
                    ),
                  ),
                  _shimmerBox(width: 60, height: 20, radius: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _shimmerBox(height: 10)),
                  const SizedBox(width: 10),
                  Expanded(child: _shimmerBox(height: 10)),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _shimmerBox(height: 10)),
                ],
              ),
            ),
            Container(height: 1, color: _C.divider),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: List.generate(2, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == 0 ? 12 : 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 7),
                                decoration: const BoxDecoration(
                                  color: _C.divider,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(child: _shimmerBox(height: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _shimmerBox(height: 20, radius: 8)),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: _shimmerBox(height: 11)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
