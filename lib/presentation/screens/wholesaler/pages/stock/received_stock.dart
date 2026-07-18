import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controller/received_stock_controller.dart';

class ReceivedStock extends StatefulWidget {
  const ReceivedStock({super.key});

  @override
  State<ReceivedStock> createState() => _ReceivedStockState();
}

class _ReceivedStockState extends State<ReceivedStock> {
  late final ReceivedStockController controller;
  final TextEditingController searchController = TextEditingController();
  String _search = "";
  String _selectedFilter = "All";

  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF8640F6);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _purpleBorder = Color(0xFFD4C8F7);
  static const Color _green = Color(0xFF00B87A);
  static const Color _greenBg = Color(0xFFE6F9F2);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);

  final List<String> _filters = ["All", "Today", "This Week", "This Month"];

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReceivedStockController());
    searchController.addListener(() {
      setState(() => _search = searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _passesDateFilter(String rawDate) {
    if (_selectedFilter == "All") return true;
    try {
      final date = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      if (_selectedFilter == "Today") {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }
      if (_selectedFilter == "This Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return date.isAfter(start.subtract(const Duration(seconds: 1)));
      }
      if (_selectedFilter == "This Month") {
        return date.year == now.year && date.month == now.month;
      }
    } catch (_) {}
    return true;
  }

  List<Map<String, dynamic>> get _filtered {
    if (controller.stockList.isEmpty) return [];
    return controller.stockList.where((item) {
      final matchSearch =
          _search.isEmpty ||
          (item["drug_name"] ?? "").toString().toLowerCase().contains(
            _search,
          ) ||
          (item["batch_no"] ?? "").toString().toLowerCase().contains(_search);
      final matchDate = _passesDateFilter(
        item["received_date"]?.toString() ?? "",
      );
      return matchSearch && matchDate;
    }).toList();
  }

  String _formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return "-";
    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;
      final time = DateFormat('hh:mm a').format(date);

      if (diff == 0) return "Today • $time";
      if (diff == 1) return "Yesterday • $time";
      if (diff < 7 && diff > 0)
        return "${DateFormat('EEEE').format(date)} • $time";
      if (date.year == now.year)
        return DateFormat('dd MMM • hh:mm a').format(date);
      return DateFormat('dd MMM yyyy • hh:mm a').format(date);
    } catch (_) {
      return value;
    }
  }

  Widget _buildSummaryBanner(List<Map<String, dynamic>> items) {
    final totalQty = items.fold<int>(
      0,
      (sum, e) =>
          sum + (int.tryParse(e["received_qty"]?.toString() ?? "0") ?? 0),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _greenBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: _green,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${items.length} Received Item${items.length != 1 ? 's' : ''}",
                style: GoogleFonts.dmSans(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Total received qty: $totalQty units",
                style: GoogleFonts.dmSans(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final qty = item["received_qty"]?.toString() ?? "0";
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: _greenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: _green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["drug_name"] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Batch: ${item["batch_no"] ?? "-"}",
                        style: GoogleFonts.dmSans(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "+$qty",
                      style: GoogleFonts.dmSans(
                        color: _green,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "RECEIVED",
                        style: GoogleFonts.dmSans(
                          color: _green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateTime(item["received_date"]?.toString()),
                      style: GoogleFonts.dmSans(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _purple : _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? _purple : _divider, width: 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _purple.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? Colors.white : _textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonSummaryBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _greenBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BlinkingSkeleton(width: 110, height: 18, borderRadius: 4),
              SizedBox(height: 6),
              _BlinkingSkeleton(width: 160, height: 12, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: _greenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const _BlinkingSkeleton(
                  width: 46,
                  height: 46,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BlinkingSkeleton(
                        width: 120,
                        height: 16,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 6),
                      _BlinkingSkeleton(width: 80, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const _BlinkingSkeleton(
                      width: 40,
                      height: 20,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 70,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    _BlinkingSkeleton(width: 14, height: 14, borderRadius: 3),
                    SizedBox(width: 6),
                    _BlinkingSkeleton(width: 130, height: 12, borderRadius: 3),
                  ],
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
    final width = MediaQuery.of(context).size.width;
    final double horizontalPad = width > 900
        ? width * 0.18
        : width > 600
        ? width * 0.08
        : 16;
    return Scaffold(
      backgroundColor: _bg,
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
          "Received Stock",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          final items = _filtered;
          final bool loading = controller.isLoading.value;
          return RefreshIndicator(
            color: _purple,
            backgroundColor: _surface,
            onRefresh: controller.loadReceivedStock,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      0,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _purpleBorder,
                              width: 1.2,
                            ),
                          ),
                          child: TextField(
                            controller: searchController,
                            style: GoogleFonts.dmSans(
                              color: _textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search Drug / Batch...",
                              hintStyle: GoogleFonts.dmSans(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: _purple.withOpacity(0.6),
                                size: 20,
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: _textSecondary,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() => _search = "");
                                      },
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters
                                .map((f) => _buildFilterChip(f))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: _divider),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loading
                                ? "Loading..."
                                : "${items.length} record${items.length != 1 ? 's' : ''}",
                            style: GoogleFonts.dmSans(
                              color: _textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (loading)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      14,
                      horizontalPad,
                      30,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSkeletonSummaryBanner(),
                        _buildSkeletonCard(),
                        _buildSkeletonCard(),
                      ]),
                    ),
                  )
                else if (controller.stockList.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
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
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 40,
                                color: _purple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Received Stock Found",
                              style: GoogleFonts.dmSans(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Pull down to refresh",
                              style: GoogleFonts.dmSans(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 52,
                              color: _textSecondary.withOpacity(0.4),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "No records match",
                              style: GoogleFonts.dmSans(
                                color: _textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try a different search or filter",
                              style: GoogleFonts.dmSans(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      14,
                      horizontalPad,
                      30,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              _buildSummaryBanner(items),
                              _buildCard(items[index]),
                            ],
                          );
                        }
                        return _buildCard(items[index]);
                      }, childCount: items.length),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BlinkingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const _BlinkingSkeleton({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });
  @override
  State<_BlinkingSkeleton> createState() => _BlinkingSkeletonState();
}

class _BlinkingSkeletonState extends State<_BlinkingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: 0.35 + (_controller.value * 0.4), child: child);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E0F5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
