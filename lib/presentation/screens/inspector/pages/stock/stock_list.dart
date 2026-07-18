import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/stock_info_controller.dart';
import 'stock_details.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const rose = Color(0xFFBE123C);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class StockListScreen extends StatelessWidget {
  StockListScreen({super.key});
  final StockInfoController controller = Get.put(StockInfoController());
  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 1000) return w * 0.28;
    if (w > 700) return w * 0.12;
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

  Widget _searchField() {
    return Obx(
      () => Container(
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
          onChanged: controller.onSearch,
          textInputAction: TextInputAction.search,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search name, shop or DL No...',
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
            suffixIcon: controller.hasSearchText.value
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: const Icon(
                      Icons.close_rounded,
                      color: _C.textSub,
                      size: 18,
                    ),
                  )
                : null,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _typeSelector() {
    return Obx(
      () => Row(
        children: [
          _typeChip('retailer', Icons.store_rounded, _C.green, _C.greenSoft),
          const SizedBox(width: 10),
          _typeChip(
            'wholesaler',
            Icons.warehouse_rounded,
            _C.blue,
            _C.blueSoft,
          ),
        ],
      ),
    );
  }

  Widget _typeChip(
    String type,
    IconData icon,
    Color activeColor,
    Color activeBg,
  ) {
    final selected = controller.selectedType.value == type;
    final label = type[0].toUpperCase() + type.substring(1);
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? activeColor : _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? activeColor : _C.divider,
              width: selected ? 0 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected ? activeColor.withOpacity(0.18) : _C.shadow,
                blurRadius: selected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : activeColor,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? Colors.white : _C.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final name = (user['name'] ?? '').toString();
    final business = controller.getBusinessName(user);
    final displayBusiness = business.isNotEmpty ? business : 'No Shop Name';
    final dlNumber = (user['drug_license_no'] ?? '').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final itemType = (user['type'] ?? controller.selectedType.value).toString();
    final isRetailer =
        itemType == 'retailer' || (controller.selectedType.value == 'retailer');
    final chipColor = isRetailer ? _C.green : _C.blue;
    final chipBg = isRetailer ? _C.greenSoft : _C.blueSoft;
    final chipLabel = isRetailer ? 'RETAILER' : 'WHOLESALER';
    return GestureDetector(
      onTap: () {
        final userId = controller.getUserId(user);
        if (userId <= 0) {
          Get.snackbar(
            'Error',
            'Invalid User ID',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _C.rose,
            colorText: Colors.white,
            margin: const EdgeInsets.all(14),
            borderRadius: 14,
          );
          return;
        }
        Get.to(
          () => StockDetailsScreen(userId: userId, title: displayBusiness),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
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
                    name.isNotEmpty ? name : 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    displayBusiness,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: _C.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dlNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'DL: $dlNumber',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: _C.indigo,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chipLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: chipColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _C.indigoSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: _C.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 6,
          itemBuilder: (_, __) => const _SkeletonCard(),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
        );
      }
      if (controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                'No Data Found',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different name or switch type',
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
      return RefreshIndicator(
        color: _C.indigo,
        onRefresh: controller.refreshData,
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.users.length,
          itemBuilder: (_, i) => _userCard(controller.users[i]),
        ),
      );
    });
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
          'Stock Tracking',
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Search'),
              _searchField(),
              const SizedBox(height: 16),
              _sectionLabel('Filter by Type'),
              _typeSelector(),
              const SizedBox(height: 16),
              _sectionLabel('Results'),
              Expanded(child: _buildBody()),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
            _shimmerBox(width: 46, height: 46, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 140, height: 14),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 100, height: 11),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 120, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _shimmerBox(width: 70, height: 22, radius: 10),
                const SizedBox(height: 8),
                _shimmerBox(width: 32, height: 32, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
