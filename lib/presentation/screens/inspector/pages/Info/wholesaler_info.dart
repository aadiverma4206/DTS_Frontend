import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/wholesaler_info_controller.dart';
import 'wholesaler_info_details.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class WholesalerInfoScreen extends StatelessWidget {
  WholesalerInfoScreen({super.key});
  final controller = Get.put(WholesalerInfoController());
  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.10;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final hPad = _hPad(context);
    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Wholesalers',
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
              child: _searchField(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
              child: _sectionLabel('Wholesalers'),
            ),
            Expanded(child: Obx(() => _buildBody(context, hPad))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double hPad) {
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
    if (controller.errorMessage.value.isNotEmpty) {
      return _errorView();
    }
    if (controller.filteredWholesalers.isEmpty) {
      return _emptyView();
    }
    return RefreshIndicator(
      color: _C.indigo,
      onRefresh: controller.refreshData,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          hPad,
          0,
          hPad,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        itemCount: controller.filteredWholesalers.length,
        itemBuilder: (context, index) {
          final item = controller.filteredWholesalers[index];
          return _wholesalerCard(item);
        },
      ),
    );
  }

  Widget _searchField() {
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
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search name / shop / DL no...',
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

  Widget _wholesalerCard(Map<String, dynamic> item) {
    final name = (item['name'] ?? '').toString();
    final company = (item['company_name'] ?? '').toString();
    final dl = (item['drug_license_no'] ?? '').toString();
    final mobile = (item['mobile'] ?? '').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () {
        final dynamic id = item['user_id'];
        if (id == null) {
          Get.snackbar(
            'Error',
            'Invalid wholesaler ID',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _C.rose,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        final int userId = int.tryParse(id.toString()) ?? 0;
        if (userId <= 0) {
          Get.snackbar(
            'Error',
            'Invalid wholesaler ID',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _C.rose,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        Get.to(() => WholesalerInfoDetailsScreen(userId: userId));
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
                color: _C.blueSoft,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _C.blue,
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
                        if (company.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            company,
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
                      color: _C.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'WHOLESALER',
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
                  if (dl.isNotEmpty)
                    _infoRow(Icons.badge_rounded, 'DL No.', dl, _C.blue),
                  if (mobile.isNotEmpty)
                    _infoRow(Icons.phone_rounded, 'Mobile', mobile, _C.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
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
      ),
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
              Icons.person_search_rounded,
              size: 30,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Wholesalers Found',
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

  Widget _errorView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _C.rose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 38,
                  color: _C.rose,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: _C.rose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Retry',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
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
                color: _C.blueSoft,
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
