import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/stock_details_controller.dart';

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

class StockDetailsScreen extends StatelessWidget {
  final int userId;
  final String title;
  const StockDetailsScreen({
    super.key,
    required this.userId,
    required this.title,
  });
  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.10;
    return 16;
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

  Widget _searchField(StockDetailsController c, {required bool isExpired}) {
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
        onChanged: isExpired ? c.setExpiredSearch : c.setAvailableSearch,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: isExpired
              ? 'Search expired drug...'
              : 'Search supplier, drug, DL...',
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

  Widget _emptyState({required String message, required String sub}) {
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
              Icons.inventory_2_outlined,
              size: 30,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
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

  Widget _availableStockCard(
    Map<String, dynamic> supplier,
    List<Map<String, dynamic>> drugs,
  ) {
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
            decoration: const BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _C.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
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
                        supplier['supplier_name']?.toString() ?? '-',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supplier['supplier_shop']?.toString() ?? '-',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: _C.textSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'DL: ${supplier['drug_license_no'] ?? '-'}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: _C.indigo,
                          fontWeight: FontWeight.w700,
                        ),
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
                    color: _C.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${drugs.length} drugs',
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
                    'Total',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _C.textSub,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sold',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _C.textSub,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Avl',
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
              children: drugs.asMap().entries.map((entry) {
                final i = entry.key;
                final drug = entry.value;
                final isLast = i == drugs.length - 1;
                final available = (drug['available_stock'] ?? 0) as num;
                final isLow = available <= 5;
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
                                decoration: const BoxDecoration(
                                  color: _C.indigo,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  drug['drug_name']?.toString() ?? '-',
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
                              color: _C.blueSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (drug['total_stock'] ?? 0).toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.blue,
                              ),
                            ),
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
                              color: _C.amberSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (drug['sold_stock'] ?? 0).toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.amber,
                              ),
                            ),
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
                              color: isLow ? _C.roseSoft : _C.greenSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              available.toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isLow ? _C.rose : _C.green,
                              ),
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

  Widget _expiredStockCard(List<Map<String, dynamic>> items) {
    return Container(
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
              color: _C.roseSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _C.rose,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Expired & Unsold Items',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _C.rose,
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
                    'Expiry',
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
                                decoration: const BoxDecoration(
                                  color: _C.rose,
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
                              color: _C.roseSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (item['quantity'] ?? 0).toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.rose,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item['expiry_date']?.toString() ?? '-',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.rose,
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

  Widget _buildBody(StockDetailsController c) {
    return Obx(() {
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
                'Failed to load stock details',
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Available Stock'),
          _buildAvailableList(c),
          const SizedBox(height: 20),
          _sectionLabel('Search Expired Stock'),
          _searchField(c, isExpired: true),
          const SizedBox(height: 20),
          _sectionLabel('Expired Stock (Not Sold)'),
          _buildExpiredList(c),
        ],
      );
    });
  }

  Widget _buildAvailableList(StockDetailsController c) {
    return Obx(() {
      if (c.isLoading.value && c.availableStock.isEmpty) {
        return Column(
          children: List.generate(2, (_) => const _SkeletonAvailableCard()),
        );
      }
      final suppliers = c.filteredAvailableStock;
      if (suppliers.isEmpty) {
        return _emptyState(
          message: 'No Stock Found',
          sub: 'Try a different search',
        );
      }
      return Column(
        children: suppliers.map((supplier) {
          final drugs = c.getDrugs(supplier);
          return _availableStockCard(supplier, drugs);
        }).toList(),
      );
    });
  }

  Widget _buildExpiredList(StockDetailsController c) {
    return Obx(() {
      if (c.isLoading.value && c.expiredStock.isEmpty) {
        return const _SkeletonExpiredCard();
      }
      final expired = c.filteredExpiredStock;
      if (expired.isEmpty) {
        return _emptyState(
          message: 'No Expired Stock',
          sub: 'All good — nothing expired here',
        );
      }
      return _expiredStockCard(expired);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      StockDetailsController(userId),
      tag: 'stock-$userId',
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
          'Stock Details',
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
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('Search Available Stock'),
                    _searchField(controller, isExpired: false),
                    const SizedBox(height: 20),
                    _buildBody(controller),
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

class _SkeletonAvailableCard extends StatefulWidget {
  const _SkeletonAvailableCard();
  @override
  State<_SkeletonAvailableCard> createState() => _SkeletonAvailableCardState();
}

class _SkeletonAvailableCardState extends State<_SkeletonAvailableCard>
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
                        _shimmerBox(width: 140, height: 14),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 100, height: 10),
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
                  Expanded(child: _shimmerBox(height: 10)),
                  const SizedBox(width: 10),
                  Expanded(child: _shimmerBox(height: 10)),
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
                        Expanded(child: _shimmerBox(height: 20, radius: 8)),
                        const SizedBox(width: 10),
                        Expanded(child: _shimmerBox(height: 20, radius: 8)),
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

class _SkeletonExpiredCard extends StatefulWidget {
  const _SkeletonExpiredCard();
  @override
  State<_SkeletonExpiredCard> createState() => _SkeletonExpiredCardState();
}

class _SkeletonExpiredCardState extends State<_SkeletonExpiredCard>
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
                color: _C.roseSoft,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  _shimmerBox(width: 40, height: 40, radius: 12),
                  const SizedBox(width: 12),
                  Expanded(child: _shimmerBox(width: 150, height: 14)),
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
                                  color: _C.rose,
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
