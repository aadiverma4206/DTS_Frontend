import 'package:drug_tracking_system/core/services/api_service/stock_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stock_detail_screen.dart';
import 'package:intl/intl.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> stock = [];
  List<Map<String, dynamic>> filteredStock = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF8640F6);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);
  static const Color _lowStockColor = Color(0xFFE8455A);
  static const Color _lowStockBg = Color(0xFFFDECEF);
  static const Color _okStockColor = Color(0xFF00B87A);
  static const Color _okStockBg = Color(0xFFE6F9F2);
  String formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    searchController.addListener(_filterStock);
    loadStock();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _filterStock() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      filteredStock = query.isEmpty
          ? List.from(stock)
          : stock.where((item) {
              return item["drug_name"].toString().toLowerCase().contains(
                    query,
                  ) ||
                  item["batch_no"].toString().toLowerCase().contains(query);
            }).toList();
    });
  }

  Future<void> loadStock() async {
    setState(() => isLoading = true);
    try {
      final data = await StockApi.getStock();
      if (!mounted) return;
      final mapped = data.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          "batch_id": int.tryParse(m["batch_id"]?.toString() ?? "") ?? 0,
          "drug_name": m["drug_name"]?.toString() ?? "",
          "batch_no": m["batch_no"]?.toString() ?? "",
          "quantity": int.tryParse(m["quantity"]?.toString() ?? "") ?? 0,
          "manufacturer_name": m["manufacturer_name"]?.toString() ?? "",
          "mrp": double.tryParse(m["mrp"]?.toString() ?? "0") ?? 0.0,
          "expiry_date": m["expiry_date"]?.toString() ?? "",
          "created_at": m["created_at"]?.toString() ?? "",
        };
      }).toList();
      setState(() {
        stock = mapped;
        filteredStock = List.from(mapped);
        isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception:", "").trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _lowStockColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    }
  }

  int get lowStockCount =>
      stock.where((item) => (item["quantity"] as int) < 20).length;
  int get totalItems => stock.length;
  Widget _buildSummaryCard(
    String label,
    int count,
    Color color,
    Color bgColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? _BlinkingSkeleton(
                        child: Container(
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _divider,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                    : Text(
                        count.toString(),
                        style: GoogleFonts.spaceGrotesk(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> item) {
    final int batchId = item["batch_id"] ?? 0;
    final int qty = item["quantity"] as int;
    final bool isLow = qty < 20;
    final Color accent = isLow ? _lowStockColor : _okStockColor;
    final Color accentBg = isLow ? _lowStockBg : _okStockBg;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: batchId == 0
            ? null
            : () => Get.to(() => StockDetailScreen(batchId: batchId)),
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
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["drug_name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Batch: ${item["batch_no"]}",
                            style: GoogleFonts.inter(
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
                          qty.toString(),
                          style: GoogleFonts.spaceGrotesk(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isLow ? "LOW" : "IN STOCK",
                            style: GoogleFonts.inter(
                              color: accent,
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
                    if (item["manufacturer_name"].toString().isNotEmpty)
                      _buildDetailRow(
                        Icons.business_rounded,
                        "Manufacturer",
                        item["manufacturer_name"],
                        _purple,
                      ),
                    if (item["mrp"] != null && item["mrp"] != 0.0) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.currency_rupee_rounded,
                        "MRP",
                        "₹${(item["mrp"] as double).toStringAsFixed(2)}",
                        _okStockColor,
                      ),
                    ],
                    if (item["expiry_date"].toString().isNotEmpty) ...[
                      if (item["expiry_date"].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.event_rounded,
                          "Expiry",
                          item["expiry_date"],
                          _lowStockColor,
                        ),
                      ],
                      if (item["created_at"].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.access_time_rounded,
                          "Created",
                          formatDateTime(item["created_at"]),
                          Colors.blue,
                        ),
                      ],
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: _textSecondary,
                        ),
                        Text(
                          "View Details",
                          style: GoogleFonts.inter(
                            color: _purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor.withOpacity(0.75)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.inter(
            color: _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
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
    );
  }

  Widget _buildStockSkeletonCard() {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _divider,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 15,
                        decoration: BoxDecoration(
                          color: _divider,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _divider,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(6),
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
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 120,
                      height: 13,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 13,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildSkeletonList() {
    return _BlinkingSkeleton(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => _buildStockSkeletonCard(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
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
                Icons.inventory_2_outlined,
                size: 40,
                color: _purple.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No stock found",
              style: GoogleFonts.spaceGrotesk(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try adjusting your search",
              style: GoogleFonts.inter(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
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
    final bool canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
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
          "My Stock",
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            color: _purple,
            backgroundColor: _surface,
            onRefresh: loadStock,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildSummaryCard(
                              "Total Items",
                              totalItems,
                              _purple,
                              _purpleSoft,
                              Icons.inventory_2_rounded,
                            ),
                            const SizedBox(width: 12),
                            _buildSummaryCard(
                              "Low Stock",
                              lowStockCount,
                              _lowStockColor,
                              _lowStockBg,
                              Icons.warning_amber_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _divider, width: 1.2),
                          ),
                          child: TextField(
                            controller: searchController,
                            style: GoogleFonts.inter(
                              color: _textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search drug or batch number...",
                              hintStyle: GoogleFonts.inter(
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
                                        _filterStock();
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
                        Container(height: 1, color: _divider),
                        const SizedBox(height: 8),
                        Text(
                          "${filteredStock.length} item${filteredStock.length != 1 ? "s" : ""}",
                          style: GoogleFonts.inter(
                            color: _textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    14,
                    horizontalPad,
                    30,
                  ),
                  sliver: isLoading
                      ? SliverToBoxAdapter(child: _buildSkeletonList())
                      : filteredStock.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildStockCard(filteredStock[index]),
                            childCount: filteredStock.length,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingSkeleton extends StatefulWidget {
  final Widget child;
  const _BlinkingSkeleton({required this.child});
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
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 0.85,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
