import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/drug_WR_controller.dart';
import 'drug_WR_details_screen.dart';

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

class DrugWRFilterScreen extends StatelessWidget {
  final int drugId;
  final String drugName;

  const DrugWRFilterScreen({
    super.key,
    required this.drugId,
    required this.drugName,
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(DrugWRController c) {
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
        onChanged: c.search,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search name / shop / company / DL...',
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
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _filterChips(DrugWRController c) {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
      {
        'key': 'wholesaler',
        'label': 'Wholesaler',
        'icon': Icons.local_shipping_rounded,
      },
      {'key': 'retailer', 'label': 'Retailer', 'icon': Icons.store_rounded},
    ];

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final key = f['key'] as String;
            final label = f['label'] as String;
            final icon = f['icon'] as IconData;
            final selected = c.selectedType.value == key;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => c.changeType(key),
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
      ),
    );
  }

  Widget _stockPill(String label, String value, Color bg, Color fg) {
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
              value,
              style: GoogleFonts.nunito(
                fontSize: 17,
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

  Widget _holderCard(DrugWRController c, Map<String, dynamic> item) {
    final isWS = c.isWholesaler(item);

    return GestureDetector(
      onTap: () => Get.to(
        () => DrugWRDetailsScreen(
          drugId: drugId,
          userId: c.getUserId(item),
          drugName: drugName,
          userType: c.getUserType(item),
        ),
      ),
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
              decoration: BoxDecoration(
                color: isWS ? _C.blueSoft : _C.greenSoft,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isWS ? _C.blue : _C.green,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isWS ? Icons.local_shipping_rounded : Icons.store_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.getName(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.getBusinessName(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: _C.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'DL: ${c.getLicense(item)}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: isWS ? _C.blue : _C.green,
                            fontWeight: FontWeight.w700,
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
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isWS ? _C.blue : _C.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isWS ? 'WHOLESALER' : 'RETAILER',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.getSupplyFlow(item),
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: _C.textSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _stockPill(
                    'Received',
                    c.getReceivedQty(item).toString(),
                    _C.blueSoft,
                    _C.blue,
                  ),
                  const SizedBox(width: 8),
                  _stockPill(
                    'Available',
                    c.getAvailableQty(item).toString(),
                    _C.greenSoft,
                    _C.green,
                  ),
                  const SizedBox(width: 8),
                  isWS
                      ? _stockPill(
                          'Supplied',
                          c.getSuppliedQty(item).toString(),
                          _C.amberSoft,
                          _C.amber,
                        )
                      : _stockPill(
                          'Sold',
                          c.getSoldQty(item).toString(),
                          _C.roseSoft,
                          _C.rose,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonHolderCard() {
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
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                _Shimmer(width: 42, height: 42, radius: 13),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Shimmer(width: 120, height: 14, radius: 6),
                      SizedBox(height: 6),
                      _Shimmer(width: 80, height: 12, radius: 6),
                      SizedBox(height: 6),
                      _Shimmer(width: 60, height: 12, radius: 6),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Shimmer(width: 80, height: 22, radius: 10),
                    SizedBox(height: 8),
                    _Shimmer(width: 50, height: 10, radius: 4),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                        _Shimmer(width: 40, height: 16, radius: 6),
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
                        _Shimmer(width: 40, height: 16, radius: 6),
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
                        _Shimmer(width: 40, height: 16, radius: 6),
                        SizedBox(height: 6),
                        _Shimmer(width: 50, height: 10, radius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DrugWRController(drugId: drugId, drugName: drugName),
      tag: drugId.toString(),
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
          drugName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.downloadPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: 'Download PDF',
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
                    _sectionLabel('Search'),
                    _searchField(controller),
                    const SizedBox(height: 16),
                    _sectionLabel('Filter by Type'),
                    _filterChips(controller),
                    const SizedBox(height: 16),
                    _sectionLabel('Holders'),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Column(
                          children: List.generate(
                            4,
                            (index) => _skeletonHolderCard(),
                          ),
                        );
                      }

                      if (controller.errorMessage.value.isNotEmpty) {
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
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: _C.textSub,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: controller.refreshData,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
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

                      final list = controller.filteredHolders;
                      if (list.isEmpty) {
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
                                  Icons.person_search_rounded,
                                  size: 30,
                                  color: _C.indigo,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Holders Found',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different filter or search',
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

                      return Column(
                        children: list
                            .map((item) => _holderCard(controller, item))
                            .toList(),
                      );
                    }),
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
