import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/manufacturer_list_controller.dart';
import 'manufacturer_detail_screen.dart';

class _C {
  static const bg = Color(0xFFF4F2FB);
  static const surface = Color(0xFFFFFFFF);
  static const purple = Color(0xFF025C67);
  static const purpleSoft = Color(0xFFEDE8FB);
  static const textPrimary = Color(0xFF1A1035);
  static const textSub = Color(0xFF7B7494);
  static const divider = Color(0xFFE5E0F5);
  static const shadow = Color(0x0A8640F6);
}

class ManufacturerList extends StatefulWidget {
  const ManufacturerList({super.key});

  @override
  State<ManufacturerList> createState() => _ManufacturerListState();
}

class _ManufacturerListState extends State<ManufacturerList> {
  final ManufacturerListController controller = Get.put(
    ManufacturerListController(),
  );
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.10;
    return 16;
  }

  String formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return "-";
    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;

      if (diff == 0) {
        return "Today • ${TimeOfDay.fromDateTime(date).format(context)}";
      }
      if (diff == 1) {
        return "Yesterday • ${TimeOfDay.fromDateTime(date).format(context)}";
      }
      return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year} • ${TimeOfDay.fromDateTime(date).format(context)}";
    } catch (_) {
      return value;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
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
          "Manufacturer List",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
              child: _sectionLabel('Manufacturers'),
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

    final filteredManufacturers = controller.manufacturers.where((
      manufacturer,
    ) {
      final companyName = (manufacturer["company_name"] ?? "")
          .toString()
          .toLowerCase();
      final phone = (manufacturer["phone"] ?? "").toString().toLowerCase();
      final query = searchQuery.value;
      return companyName.contains(query) || phone.contains(query);
    }).toList();

    if (filteredManufacturers.isEmpty) {
      return _emptyView();
    }

    return RefreshIndicator(
      color: _C.purple,
      onRefresh: controller.loadManufacturers,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          hPad,
          0,
          hPad,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        itemCount: filteredManufacturers.length,
        itemBuilder: (context, index) {
          final manufacturer = filteredManufacturers[index];
          return _manufacturerCard(manufacturer);
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
        controller: searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          searchQuery.value = value.trim().toLowerCase();
        },
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: "Search Manufacturer...",
          hintStyle: GoogleFonts.nunito(
            color: _C.textSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _C.purple,
            size: 20,
          ),
          suffixIcon: Obx(
            () => searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _C.textSub,
                      size: 20,
                    ),
                    onPressed: () {
                      searchController.clear();
                      searchQuery.value = '';
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
            color: _C.purple,
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

  Widget _manufacturerCard(Map<String, dynamic> manufacturer) {
    final companyName = (manufacturer["company_name"] ?? "").toString();
    final phone = (manufacturer["phone"] ?? "-").toString();
    final dateStr = formatDateTime(manufacturer["created_at"]?.toString());
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'M';

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ManufacturerDetailScreen(
            manufacturerId: manufacturer["manufacturer_id"],
          ),
        );
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
                color: _C.purpleSoft,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _C.purple,
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
                    child: Text(
                      companyName.isEmpty ? 'Unknown' : companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _C.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'MANUFACTURER',
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
                  _infoRow(Icons.phone_rounded, 'Mobile', phone, _C.purple),
                  _infoRow(
                    Icons.access_time_rounded,
                    'Created',
                    dateStr,
                    _C.purple,
                  ),
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
              color: _C.purpleSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.business_outlined,
              size: 30,
              color: _C.purple,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Manufacturer Found',
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
                color: _C.purpleSoft,
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
