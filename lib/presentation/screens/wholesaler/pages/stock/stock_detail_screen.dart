import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/services/api_service/stock_api.dart';

enum DetailFilter { all, batch, drug, pricing, manufacturer, wholesaler }

class StockDetailScreen extends StatefulWidget {
  final int batchId;
  const StockDetailScreen({super.key, required this.batchId});
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF8640F6);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _receiveColor = Color(0xFF00B87A);
  static const Color _supplyColor = Color(0xFFE8455A);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);
  Map<String, dynamic> data = {};
  bool isLoading = true;
  DetailFilter activeFilter = DetailFilter.all;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String v(dynamic x) =>
      x == null || x.toString().trim().isEmpty ? '-' : x.toString();
  String formatDateTime(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '-';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;
      if (diff == 0) return 'Today • ${DateFormat('hh:mm a').format(date)}';
      if (diff == 1) return 'Yesterday • ${DateFormat('hh:mm a').format(date)}';
      return DateFormat('dd MMM yyyy • hh:mm a').format(date);
    } catch (_) {
      return value.toString();
    }
  }

  List<Map<String, dynamic>> get _allSections => [
    {
      'filter': DetailFilter.batch,
      'label': 'Batch Information',
      'icon': Icons.inventory_2_rounded,
      'color': _purple,
      'fields': [
        {'title': 'Batch Number', 'value': v(data['batch_no'])},
        {'title': 'Quantity Available', 'value': v(data['quantity'])},
        {
          'title': 'Manufacture Date',
          'value': formatDateTime(data['manufacture_date']),
        },
        {'title': 'Expiry Date', 'value': formatDateTime(data['expiry_date'])},
        {
          'title': 'Receive Date',
          'value': formatDateTime(data['stock_receive_date']),
        },
        {'title': 'Status', 'value': v(data['status'])},
      ],
    },
    {
      'filter': DetailFilter.drug,
      'label': 'Drug Information',
      'icon': Icons.medication_rounded,
      'color': _receiveColor,
      'fields': [
        {'title': 'Medicine Name', 'value': v(data['drug_name'])},
        {'title': 'Composition', 'value': v(data['composition'])},
        {'title': 'Category', 'value': v(data['category'])},
        {'title': 'Dosage Form', 'value': v(data['dosage_form'])},
        {'title': 'Strength', 'value': v(data['strength'])},
      ],
    },
    {
      'filter': DetailFilter.pricing,
      'label': 'Pricing Details',
      'icon': Icons.currency_rupee_rounded,
      'color': const Color(0xFFE8A200),
      'fields': [
        {'title': 'MRP', 'value': v(data['mrp'])},
        {'title': 'Purchase Price', 'value': v(data['purchase_price'])},
      ],
    },
    {
      'filter': DetailFilter.manufacturer,
      'label': 'Manufacturer Details',
      'icon': Icons.business_rounded,
      'color': const Color(0xFF0094E8),
      'fields': [
        {'title': 'Company Name', 'value': v(data['company_name'])},
        {'title': 'GSTIN', 'value': v(data['gstin'])},
        {'title': 'License No', 'value': v(data['drug_license_no'])},
        {'title': 'Address', 'value': v(data['manufacturer_address'])},
        {'title': 'Phone', 'value': v(data['manufacturer_phone'])},
        {'title': 'Email', 'value': v(data['manufacturer_email'])},
      ],
    },
    {
      'filter': DetailFilter.wholesaler,
      'label': 'Wholesaler Details',
      'icon': Icons.local_shipping_rounded,
      'color': _supplyColor,
      'fields': [
        {'title': 'Name', 'value': v(data['wholesaler_name'])},
        {'title': 'Email', 'value': v(data['wholesaler_email'])},
        {'title': 'Phone', 'value': v(data['wholesaler_phone'])},
      ],
    },
  ];
  List<Map<String, dynamic>> get _visibleSections {
    return _allSections.where((section) {
      final matchesFilter =
          activeFilter == DetailFilter.all || section['filter'] == activeFilter;
      if (!matchesFilter) return false;
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final label = (section['label'] as String).toLowerCase();
      if (label.contains(q)) return true;
      final fields = section['fields'] as List<Map<String, dynamic>>;
      return fields.any(
        (f) =>
            f['title'].toString().toLowerCase().contains(q) ||
            f['value'].toString().toLowerCase().contains(q),
      );
    }).toList();
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
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text.toLowerCase().trim());
    });
    loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final res = await StockApi.getStockDetail(widget.batchId);
      if (!mounted) return;
      setState(() {
        data = res;
        isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _supplyColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    }
  }

  Widget _buildFilterChip(
    String label,
    DetailFilter filter,
    Color activeColor,
  ) {
    final bool selected = activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? activeColor : _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? activeColor : _divider,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : _textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    final q = searchQuery;
    final valueLower = value.toLowerCase();
    final titleLower = title.toLowerCase();
    final matchesSearch =
        q.isNotEmpty && (valueLower.contains(q) || titleLower.contains(q));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: matchesSearch
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                  : EdgeInsets.zero,
              decoration: matchesSearch
                  ? BoxDecoration(
                      color: _purple.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final Color color = section['color'] as Color;
    final String label = section['label'] as String;
    final IconData icon = section['icon'] as IconData;
    final List<Map<String, dynamic>> fields =
        section['fields'] as List<Map<String, dynamic>>;
    final visibleFields = searchQuery.isEmpty
        ? fields
        : fields.where((f) {
            final q = searchQuery;
            return f['title'].toString().toLowerCase().contains(q) ||
                f['value'].toString().toLowerCase().contains(q);
          }).toList();
    if (visibleFields.isEmpty) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: visibleFields
                    .map((f) => _buildDetailRow(f['title']!, f['value']!))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = v(data['status']).toUpperCase();
    final bool isActive = status == 'ACTIVE';
    final Color color = isActive ? _receiveColor : _supplyColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_purple, const Color(0xFF602EE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v(data['drug_name']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Batch: ${v(data['batch_no'])}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox({
    double width = double.infinity,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _divider,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildSkeletonHeroCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _divider.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _skeletonBox(width: 52, height: 52, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 140, height: 18),
                const SizedBox(height: 6),
                _skeletonBox(width: 90, height: 13),
              ],
            ),
          ),
          const SizedBox(width: 14),
          _skeletonBox(width: 60, height: 22, radius: 8),
        ],
      ),
    );
  }

  Widget _buildSkeletonSectionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _divider.withOpacity(0.25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _skeletonBox(width: 40, height: 40, radius: 12),
                const SizedBox(width: 12),
                _skeletonBox(width: 130, height: 15),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      _skeletonBox(width: 110, height: 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _skeletonBox(width: double.infinity, height: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonDetails() {
    return _BlinkingSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonHeroCard(),
          _buildSkeletonSectionCard(),
          _buildSkeletonSectionCard(),
        ],
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
                Icons.search_off_rounded,
                size: 40,
                color: _purple.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.spaceGrotesk(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search or filter',
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
    final visible = _visibleSections;
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
          'Stock Details',
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
            onRefresh: loadData,
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
                              hintText: 'Search field name or value...',
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
                                        setState(() => searchQuery = '');
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
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'All',
                                DetailFilter.all,
                                _purple,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Batch',
                                DetailFilter.batch,
                                _purple,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Drug',
                                DetailFilter.drug,
                                _receiveColor,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Pricing',
                                DetailFilter.pricing,
                                const Color(0xFFE8A200),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Manufacturer',
                                DetailFilter.manufacturer,
                                const Color(0xFF0094E8),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'Wholesaler',
                                DetailFilter.wholesaler,
                                _supplyColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: _divider),
                        const SizedBox(height: 8),
                        Text(
                          isLoading
                              ? 'Loading sections...'
                              : '${visible.length} section${visible.length != 1 ? 's' : ''}',
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
                      ? SliverToBoxAdapter(child: _buildSkeletonDetails())
                      : visible.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildListDelegate([
                            if (activeFilter == DetailFilter.all &&
                                searchQuery.isEmpty)
                              _buildHeroCard(),
                            ...visible.map(_buildSection),
                          ]),
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
