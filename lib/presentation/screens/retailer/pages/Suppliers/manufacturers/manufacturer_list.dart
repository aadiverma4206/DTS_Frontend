import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../retailer/controller/manufacturer_list_controller.dart';
import 'manufacturer_detail_screen.dart';

class ManufacturerList extends StatelessWidget {
  const ManufacturerList({super.key});

  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF034E1F);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManufacturerListController());
    final width = MediaQuery.of(context).size.width;
    final double horizontalPad = width > 900
        ? width * 0.18
        : width > 600
        ? width * 0.08
        : 16;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
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
          "Manufacturers",
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            height: 28,
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _divider, width: 1.2),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.searchManufacturers,
                      textInputAction: TextInputAction.search,
                      style: GoogleFonts.inter(
                        color: _textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search manufacturer...",
                        hintStyle: GoogleFonts.inter(
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _purple.withOpacity(0.6),
                          size: 20,
                        ),
                        suffixIcon: controller.searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: _textSecondary,
                                  size: 18,
                                ),
                                onPressed: controller.clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: _divider),
                  const SizedBox(height: 8),
                  Text(
                    controller.isLoading.value
                        ? "Loading manufacturers..."
                        : "${controller.filteredManufacturers.length} manufacturer${controller.filteredManufacturers.length != 1 ? "s" : ""}",
                    style: GoogleFonts.inter(
                      color: _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        14,
                        horizontalPad,
                        30,
                      ),
                      itemCount: 4,
                      itemBuilder: (_, __) => const _BlinkingSkeletonCard(),
                    )
                  : controller.filteredManufacturers.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _purpleSoft,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.business_rounded,
                                size: 40,
                                color: _purple.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No manufacturers found",
                              style: GoogleFonts.spaceGrotesk(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try adjusting your search",
                              style: GoogleFonts.inter(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: _purple,
                      backgroundColor: _surface,
                      onRefresh: controller.loadManufacturers,
                      child: ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPad,
                          14,
                          horizontalPad,
                          30,
                        ),
                        itemCount: controller.filteredManufacturers.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredManufacturers[index];
                          final name = item["company_name"]?.toString() ?? "";
                          final dl =
                              item["drug_license_no"]?.toString() ?? "N/A";
                          final phone = item["phone"]?.toString() ?? "";
                          final initial = name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : "M";

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ManufacturerDetailScreen(
                                  manufacturerId: item["manufacturer_id"],
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: _surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _divider, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: _cardShadow,
                                    blurRadius: 14,
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
                                    decoration: const BoxDecoration(
                                      color: _purpleSoft,
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
                                            color: _purple.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: GoogleFonts.spaceGrotesk(
                                                color: _purple,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.spaceGrotesk(
                                              color: _textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: _purple,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      10,
                                      16,
                                      12,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_rounded,
                                              size: 14,
                                              color: _purple.withOpacity(0.75),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "DL: ",
                                              style: GoogleFonts.inter(
                                                color: _textSecondary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                dl,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  color: _textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (phone.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone_rounded,
                                                size: 14,
                                                color: _textSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                phone,
                                                style: GoogleFonts.inter(
                                                  color: _textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _BlinkingSkeletonCard extends StatefulWidget {
  const _BlinkingSkeletonCard();

  @override
  State<_BlinkingSkeletonCard> createState() => _BlinkingSkeletonCardState();
}

class _BlinkingSkeletonCardState extends State<_BlinkingSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
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
        color: const Color(0xFFE5E0F5).withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_animation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E0F5), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14602EE8),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFEDE8FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  _shimmerBox(width: 46, height: 46, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_shimmerBox(width: 140, height: 16)],
                    ),
                  ),
                  _shimmerBox(width: 36, height: 36, radius: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _shimmerBox(width: 14, height: 14, radius: 4),
                      const SizedBox(width: 8),
                      _shimmerBox(width: 180, height: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _shimmerBox(width: 14, height: 14, radius: 4),
                      const SizedBox(width: 8),
                      _shimmerBox(width: 110, height: 12),
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
