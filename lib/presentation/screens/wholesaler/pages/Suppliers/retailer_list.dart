import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/retailer_list_controller.dart';
import 'retailer_detail_screen.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class RetailerList extends StatelessWidget {
  const RetailerList({super.key});

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.10;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RetailerListController());
    final hPad = _hPad(context);

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Retailers',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
              child: _searchField(controller),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
              child: _sectionLabel('Retailer List'),
            ),
            Expanded(child: Obx(() => _buildBody(context, hPad, controller))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double hPad,
    RetailerListController controller,
  ) {
    if (controller.isLoading.value) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          hPad,
          0,
          hPad,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
    }
    if (controller.filteredRetailers.isEmpty) {
      return _emptyView();
    }
    return RefreshIndicator(
      color: _C.indigo,
      onRefresh: controller.loadRetailers,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          hPad,
          0,
          hPad,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        itemCount: controller.filteredRetailers.length,
        itemBuilder: (context, index) {
          final retailer = controller.filteredRetailers[index];
          return _retailerCard(retailer);
        },
      ),
    );
  }

  Widget _searchField(RetailerListController controller) {
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
        controller: controller.searchController,
        onChanged: controller.searchRetailers,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search Retailer...',
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
          suffixIcon: controller.searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.close_rounded, color: _C.textSub),
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

  Widget _sectionLabel(String text) {
    return Row(
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
    );
  }

  Widget _retailerCard(Map<String, dynamic> retailer) {
    final name = (retailer['retailer_name'] ?? '').toString();
    final shop = (retailer['shop_name'] ?? '').toString();
    final dl = (retailer['drug_license_no'] ?? '').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    return GestureDetector(
      onTap: () {
        Get.to(() => RetailerDetailScreen(retailerId: retailer['retailer_id']));
      },
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
                color: _C.greenSoft,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _C.green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Unknown' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary,
                          ),
                        ),
                        if (shop.isNotEmpty && shop != '-') ...[
                          const SizedBox(height: 2),
                          Text(
                            shop,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _C.textSub,
                              fontWeight: FontWeight.w500,
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
                      color: _C.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'RETAILER',
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  _infoRow(
                    Icons.store_rounded,
                    'Shop',
                    shop.isEmpty ? '-' : shop,
                    _C.indigo,
                    _C.indigoSoft,
                  ),
                  const SizedBox(height: 6),
                  _infoRow(
                    Icons.badge_rounded,
                    'DL No.',
                    dl.isEmpty ? '-' : dl,
                    _C.green,
                    _C.greenSoft,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color fg,
    Color bg,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: fg),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.textSub,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyView() {
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
              Icons.storefront_outlined,
              size: 30,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Retailers Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
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
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
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
                color: _C.greenSoft,
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
                        _shimmerBox(width: 130, height: 15),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 90, height: 11),
                      ],
                    ),
                  ),
                  _shimmerBox(width: 80, height: 20, radius: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _shimmerBox(width: 28, height: 28, radius: 8),
                      const SizedBox(width: 10),
                      _shimmerBox(width: 160, height: 12),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _shimmerBox(width: 28, height: 28, radius: 8),
                      const SizedBox(width: 10),
                      _shimmerBox(width: 140, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
