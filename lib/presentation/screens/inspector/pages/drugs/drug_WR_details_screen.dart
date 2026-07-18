import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/drug_WR_details_controller.dart';

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
  static const purple = Color(0xFF7E22CE);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const teal = Color(0xFF0F766E);
  static const tealSoft = Color(0xFFCCFBF1);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
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
          color: Color.lerp(
            const Color(0xFFE2E8F0),
            const Color(0xFFF8FAFC),
            _anim.value,
          ),
        ),
      ),
    );
  }
}

class DrugWRDetailsScreen extends StatelessWidget {
  final int drugId;
  final int userId;
  final String drugName;
  final String userType;

  const DrugWRDetailsScreen({
    super.key,
    required this.drugId,
    required this.userId,
    required this.drugName,
    required this.userType,
  });

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.08;
    return 16;
  }

  bool _isExpired(String date) {
    if (date.isEmpty) return false;
    try {
      return DateTime.parse(date).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _fmt(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      DrugWRDetailsController(
        drugId: drugId,
        userId: userId,
        drugName: drugName.trim(),
        userType: userType.trim(),
      ),
      tag: '${drugId}_$userId',
    );

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(c),
      body: Obx(() => _buildBody(context, c)),
    );
  }

  PreferredSizeWidget _buildAppBar(DrugWRDetailsController c) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        drugName.trim().isEmpty ? 'Drug Details' : drugName.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [
        Obx(
          () => c.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                      onPressed: c.refreshData,
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      tooltip: 'Download PDF',
                      onPressed: c.downloadPdf,
                    ),
                  ],
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
    );
  }

  Widget _buildBody(BuildContext context, DrugWRDetailsController c) {
    if (c.errorMessage.value.isNotEmpty) {
      return _errorView(c);
    }

    if (c.holder.isEmpty && !c.isLoading.value) {
      return _emptyHolderView(c);
    }

    return RefreshIndicator(
      color: _C.indigo,
      onRefresh: c.refreshData,
      child: _buildContent(context, c),
    );
  }

  Widget _buildContent(BuildContext context, DrugWRDetailsController c) {
    final hPad = _hPad(context);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              c.isLoading.value ? _skeletonHolderCard() : _holderCard(c),
              const SizedBox(height: 14),
              c.isLoading.value ? _skeletonSummaryCard() : _summaryCard(c),
              const SizedBox(height: 16),
              _searchField(c),
              const SizedBox(height: 12),
              _filterTabs(c),
              const SizedBox(height: 16),
              c.isLoading.value ? _skeletonTabContent() : _tabContent(c),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _searchField(DrugWRDetailsController c) {
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
        controller: c.searchController,
        onChanged: c.onSearch,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search batch / invoice / party...',
          hintStyle: GoogleFonts.nunito(
            fontSize: 14,
            color: _C.textSub,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _C.indigo,
            size: 20,
          ),
          suffixIcon: Obx(
            () => c.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _C.textSub,
                    ),
                    onPressed: c.clearSearch,
                  )
                : const SizedBox.shrink(),
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

  Widget _filterTabs(DrugWRDetailsController c) {
    return Obx(() {
      final tabs = c.visibleTabs;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final selected = c.selectedTab.value == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => c.changeTab(tab),
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
                            ? _C.indigo.withValues(alpha: 0.18)
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
                        tab.icon,
                        size: 14,
                        color: selected ? Colors.white : _C.indigo,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
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
      );
    });
  }

  Widget _tabContent(DrugWRDetailsController c) {
    switch (c.selectedTab.value) {
      case DetailTab.stock:
        return _stockSection(c);
      case DetailTab.batch:
        return _batchSection(c);
      case DetailTab.purchase:
        return _purchaseSection(c);
      case DetailTab.supply:
        return c.isWholesaler ? _supplySection(c) : _notAvailable('Supply');
      case DetailTab.sale:
        return c.isRetailer ? _salesSection(c) : _notAvailable('Sale');
      case DetailTab.all:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stockSection(c),
            const SizedBox(height: 14),
            _batchSection(c),
            const SizedBox(height: 14),
            _purchaseSection(c),
            if (c.isWholesaler) ...[
              const SizedBox(height: 14),
              _supplySection(c),
            ],
            if (c.isRetailer) ...[const SizedBox(height: 14), _salesSection(c)],
          ],
        );
    }
  }

  Widget _stockSection(DrugWRDetailsController c) {
    return _sectionCard(
      title: 'Stock Summary',
      icon: Icons.inventory_2_rounded,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              _statBox(
                'Received',
                c.receivedQty.value.toString(),
                _C.blue,
                _C.blueSoft,
              ),
              const SizedBox(width: 8),
              _statBox(
                'Available',
                c.totalAvailable.value.toString(),
                _C.green,
                _C.greenSoft,
              ),
              const SizedBox(width: 8),
              _statBox(
                'Expired',
                c.expiredQty.value.toString(),
                _C.rose,
                _C.roseSoft,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statBox(
                'Sold',
                c.totalSold.value.toString(),
                _C.amber,
                _C.amberSoft,
              ),
              const SizedBox(width: 8),
              _statBox(
                'Supplied',
                c.suppliedQty.value.toString(),
                _C.purple,
                _C.purpleSoft,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _batchSection(DrugWRDetailsController c) {
    final batches = c.filteredBatches;
    return _sectionCard(
      title: 'Batch Details',
      icon: Icons.qr_code_rounded,
      child: batches.isEmpty
          ? _emptyState('No batch information available.')
          : Column(
              children: batches.map((batch) => _batchTile(c, batch)).toList(),
            ),
    );
  }

  Widget _purchaseSection(DrugWRDetailsController c) {
    final history = c.filteredPurchase;
    return _sectionCard(
      title: 'Purchase History',
      icon: Icons.download_rounded,
      child: history.isEmpty
          ? _emptyState('No purchase history found.')
          : Column(
              children: history
                  .map(
                    (item) => _historyTile(
                      icon: Icons.download_rounded,
                      iconColor: _C.indigo,
                      iconBg: _C.indigoSoft,
                      invoice: c.invoiceNumber(item),
                      date: _fmt(c.invoiceDate(item)),
                      partyName: c.supplierName(item),
                      partyCompany: c.supplierCompany(item),
                      batchNo: c.batchNoFromHistory(item),
                      qty: c.quantityFromHistory(item).toString(),
                      extra: null,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _supplySection(DrugWRDetailsController c) {
    final history = c.filteredSupply;
    return _sectionCard(
      title: 'Supply History',
      icon: Icons.upload_rounded,
      child: history.isEmpty
          ? _emptyState('No supply history found.')
          : Column(
              children: history
                  .map(
                    (item) => _historyTile(
                      icon: Icons.upload_rounded,
                      iconColor: _C.amber,
                      iconBg: _C.amberSoft,
                      invoice: c.invoiceNumber(item),
                      date: _fmt(c.invoiceDate(item)),
                      partyName: c.supplierName(item),
                      partyCompany: c.supplierCompany(item),
                      batchNo: c.batchNoFromHistory(item),
                      qty: c.quantityFromHistory(item).toString(),
                      extra: null,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _salesSection(DrugWRDetailsController c) {
    final sales = c.filteredSales;
    return _sectionCard(
      title: 'Sales History',
      icon: Icons.point_of_sale_rounded,
      child: sales.isEmpty
          ? _emptyState('No sales history found.')
          : Column(
              children: sales.map((item) {
                final mob = c.patientMobile(item);
                final abha = c.patientAbha(item);
                return _historyTile(
                  icon: Icons.point_of_sale_rounded,
                  iconColor: _C.green,
                  iconBg: _C.greenSoft,
                  invoice: '',
                  date: _fmt(c.invoiceDate(item)),
                  partyName: c.supplierName(item).isEmpty
                      ? 'Unknown Patient'
                      : c.supplierName(item),
                  partyCompany: mob.isNotEmpty ? 'Mob: $mob' : '',
                  batchNo: c.batchNoFromHistory(item),
                  qty: c.quantityFromHistory(item).toString(),
                  extra: abha.isNotEmpty ? 'ABHA: $abha' : null,
                );
              }).toList(),
            ),
    );
  }

  Widget _holderCard(DrugWRDetailsController c) {
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
            decoration: BoxDecoration(
              color: c.isWholesaler ? _C.blueSoft : _C.greenSoft,
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
                    color: c.isWholesaler ? _C.blue : _C.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    c.isWholesaler
                        ? Icons.local_shipping_rounded
                        : Icons.store_rounded,
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
                        c.name.isEmpty ? 'Unknown' : c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                      if (c.businessName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          c.businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      Text(
                        'DL: ${c.drugLicense.isEmpty ? '-' : c.drugLicense}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.isWholesaler ? _C.blue : _C.green,
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
                    color: c.isWholesaler ? _C.blue : _C.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    c.isWholesaler ? 'WHOLESALER' : 'RETAILER',
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
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (c.mobile.isNotEmpty) _infoRow('Mobile', c.mobile),
                if (c.email.isNotEmpty) _infoRow('Email', c.email),
                if (c.gstin.isNotEmpty) _infoRow('GSTIN', c.gstin),
                if (c.address.isNotEmpty) _infoRow('Address', c.address),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(DrugWRDetailsController c) {
    return _sectionCard(
      title: 'Quick Overview',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              _statBox(
                'Received',
                c.receivedQty.value.toString(),
                _C.blue,
                _C.blueSoft,
              ),
              const SizedBox(width: 8),
              _statBox(
                'Available',
                c.totalAvailable.value.toString(),
                _C.green,
                _C.greenSoft,
              ),
              const SizedBox(width: 8),
              _statBox(
                'Expired',
                c.expiredQty.value.toString(),
                _C.rose,
                _C.roseSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                Icon(icon, size: 16, color: _C.indigo),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value.isEmpty ? '0' : value,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _batchTile(DrugWRDetailsController c, Map<String, dynamic> batch) {
    final expiry = c.batchExpiry(batch);
    final expired = _isExpired(expiry);
    final batchNo = c.batchNumber(batch);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expired ? _C.roseSoft : _C.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expired ? _C.rose.withValues(alpha: 0.3) : _C.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: expired ? _C.roseSoft : _C.indigoSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.qr_code_rounded,
                  size: 14,
                  color: expired ? _C.rose : _C.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  batchNo.isEmpty ? 'N/A' : batchNo,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _C.textPrimary,
                  ),
                ),
              ),
              if (expired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _C.rose,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'EXPIRED',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _miniStat(
                      'Received',
                      c.batchReceivedQty(batch).toString(),
                      _C.blue,
                    ),
                    const SizedBox(height: 6),
                    _miniStat(
                      'Supplied',
                      c.batchSuppliedQty(batch).toString(),
                      _C.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _miniStat(
                      'Available',
                      c.batchAvailableQty(batch).toString(),
                      _C.green,
                    ),
                    const SizedBox(height: 6),
                    _miniStat(
                      'MRP',
                      c.batchMrp(batch).isEmpty ? '-' : '₹${c.batchMrp(batch)}',
                      _C.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: _C.divider),
          const SizedBox(height: 10),
          _infoRow('Mfg Date', _fmt(c.batchManufacture(batch))),
          _infoRow(
            'Expiry',
            _fmt(expiry),
            valueColor: expired ? _C.rose : null,
          ),
          _infoRow(
            'Purchase Price',
            c.batchPurchasePrice(batch).isEmpty
                ? '-'
                : '₹${c.batchPurchasePrice(batch)}',
          ),
          _infoRow('Manufacturer', c.manufacturerName(batch)),
          _infoRow('Mfr DL', c.manufacturerDL(batch)),
          _infoRow('Mfr GSTIN', c.manufacturerGST(batch)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.textSub,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String invoice,
    required String date,
    required String partyName,
    required String partyCompany,
    required String batchNo,
    required String qty,
    required String? extra,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        partyName.isEmpty ? 'N/A' : partyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _C.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qty: $qty',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (partyCompany.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    partyCompany,
                    style: GoogleFonts.nunito(fontSize: 12, color: _C.textSub),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (invoice.isNotEmpty)
                      _chip('INV: $invoice', _C.blue, _C.blueSoft),
                    if (batchNo.isNotEmpty)
                      _chip('Batch: $batchNo', _C.purple, _C.purpleSoft),
                    if (date.isNotEmpty && date != '-')
                      _chip(date, _C.textSub, _C.bg),
                    if (extra != null && extra.isNotEmpty)
                      _chip(extra, _C.teal, _C.tealSoft),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textSub,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.nunito(color: _C.textSub, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? _C.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                color: _C.indigo,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              msg,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: _C.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notAvailable(String section) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
      ),
      child: Center(
        child: Text(
          '$section is not applicable for ${userType.toLowerCase()}s.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: _C.textSub,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _errorView(DrugWRDetailsController c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.roseSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: _C.rose,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: _C.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: c.refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _C.indigo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHolderView(DrugWRDetailsController c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_off_rounded,
              size: 30,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Holder not found',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No information available for this holder.',
            style: GoogleFonts.nunito(fontSize: 13, color: _C.textSub),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: c.refreshData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _C.indigo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Refresh',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonHolderCard() {
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
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                _Shimmer(width: 48, height: 48, radius: 14),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(width: 120, height: 16, radius: 6),
                      SizedBox(height: 6),
                      _Shimmer(width: 150, height: 12, radius: 6),
                      SizedBox(height: 6),
                      _Shimmer(width: 80, height: 12, radius: 6),
                    ],
                  ),
                ),
                _Shimmer(width: 90, height: 24, radius: 10),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 60, height: 12, radius: 4),
                    _Shimmer(width: 100, height: 12, radius: 4),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 60, height: 12, radius: 4),
                    _Shimmer(width: 120, height: 12, radius: 4),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 60, height: 12, radius: 4),
                    _Shimmer(width: 90, height: 12, radius: 4),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 60, height: 12, radius: 4),
                    _Shimmer(width: 180, height: 12, radius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonSummaryCard() {
    return _sectionCard(
      title: 'Quick Overview',
      icon: Icons.bar_chart_rounded,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _Shimmer(width: 40, height: 18, radius: 6),
                  SizedBox(height: 6),
                  _Shimmer(width: 50, height: 10, radius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _Shimmer(width: 40, height: 18, radius: 6),
                  SizedBox(height: 6),
                  _Shimmer(width: 50, height: 10, radius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _Shimmer(width: 40, height: 18, radius: 6),
                  SizedBox(height: 6),
                  _Shimmer(width: 50, height: 10, radius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonTabContent() {
    return _sectionCard(
      title: 'Details',
      icon: Icons.list_rounded,
      child: Column(
        children: List.generate(3, (index) => _skeletonDetailTile()),
      ),
    );
  }

  Widget _skeletonDetailTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Shimmer(width: 36, height: 36, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Shimmer(width: 100, height: 14, radius: 6),
                    _Shimmer(width: 50, height: 20, radius: 8),
                  ],
                ),
                SizedBox(height: 6),
                _Shimmer(width: 140, height: 12, radius: 4),
                SizedBox(height: 8),
                Row(
                  children: [
                    _Shimmer(width: 80, height: 18, radius: 6),
                    SizedBox(width: 6),
                    _Shimmer(width: 60, height: 18, radius: 6),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
