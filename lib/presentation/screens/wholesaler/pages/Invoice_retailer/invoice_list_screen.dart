import 'dart:async';
import 'package:drug_tracking_system/core/services/api_service/invoice_api.dart';
import 'package:drug_tracking_system/presentation/screens/wholesaler/pages/Invoice_retailer/invoice_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFEF3C7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const slate = Color(0xFF475569);
  static const slateSoft = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});
  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> buyers = [];
  bool isLoading = false;
  int? selectedBuyerId;
  String selectedBuyerName = "";
  String _dateFilter = "all"; // 'all', 'today', 'week', 'month'
  final TextEditingController _searchController = TextEditingController();
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final parsed = DateTime.parse(date).toLocal();
      return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parse(date, true).toLocal();
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsed);
      } catch (_) {
        return date;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadBuyers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _clearSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.clear();
        setState(() {});
      }
    });
  }

  Future<void> loadBuyers() async {
    try {
      final data = await InvoiceApi.getBuyers();
      if (!mounted) return;
      setState(() => buyers = data);
    } catch (_) {}
  }

  Future<void> selectRetailer() async {
    if (buyers.isEmpty) await loadBuyers();
    if (buyers.isEmpty || !mounted) return;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RetailerBottomSheet(
        buyers: buyers,
        selectedBuyerId: selectedBuyerId,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        selectedBuyerId = result["user_id"];
        selectedBuyerName = result["name"] ?? "";
      });
      _clearSearch();
      loadInvoices(selectedBuyerId!);
    }
  }

  Future<void> loadInvoices(int buyerId) async {
    setState(() => isLoading = true);
    try {
      final data = await InvoiceApi.getInvoicesByBuyer(buyerId);
      final parsed = data.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          "invoice_id": int.tryParse(m["invoice_id"]?.toString() ?? "0") ?? 0,
          "invoice_number": m["invoice_number"]?.toString() ?? "",
          "total_amount":
              double.tryParse(m["total_amount"]?.toString() ?? "0") ?? 0.0,
          "invoice_date": m["invoice_date"]?.toString() ?? "",
          "status": m["status"]?.toString().toLowerCase() ?? "pending",
        };
      }).toList();
      final validInvoices = parsed.where((e) => e["invoice_id"] != 0).toList();
      if (!mounted) return;
      setState(() {
        invoices = validInvoices;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return _C.blue;
      case "delivered":
        return _C.green;
      case "rejected":
        return _C.rose;
      case "pending":
      default:
        return _C.amber;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case "accepted":
        return _C.blueSoft;
      case "delivered":
        return _C.greenSoft;
      case "rejected":
        return _C.roseSoft;
      case "pending":
      default:
        return _C.amberSoft;
    }
  }

  bool _matchesDateFilter(String? dateStr, String filter) {
    if (filter == 'all') return true;
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      DateTime date;
      try {
        date = DateTime.parse(dateStr).toLocal();
      } catch (_) {
        try {
          date = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).parse(dateStr, true).toLocal();
        } catch (_) {
          return false;
        }
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final invoiceDay = DateTime(date.year, date.month, date.day);
      if (filter == 'today') {
        return invoiceDay.isAtSameMomentAs(today);
      } else if (filter == 'week') {
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final nextMonday = monday.add(const Duration(days: 7));
        return (invoiceDay.isAtSameMomentAs(monday) ||
                invoiceDay.isAfter(monday)) &&
            invoiceDay.isBefore(nextMonday);
      } else if (filter == 'month') {
        return date.year == now.year && date.month == now.month;
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> get _filtered {
    final query = _searchController.text.toLowerCase().trim();
    return invoices.where((invoice) {
      final invoiceNumber = (invoice["invoice_number"] ?? "")
          .toString()
          .toLowerCase();
      final status = (invoice["status"] ?? "").toString().toLowerCase();
      final amount = (invoice["total_amount"] ?? "").toString().toLowerCase();
      final dateStr = (invoice["invoice_date"] ?? "").toString();
      final matchSearch =
          query.isEmpty ||
          invoiceNumber.contains(query) ||
          status.contains(query) ||
          amount.contains(query) ||
          dateStr.toLowerCase().contains(query);
      final matchDate = _matchesDateFilter(dateStr, _dateFilter);
      return matchSearch && matchDate;
    }).toList();
  }

  double _hPad(double w) {
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16;
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _retailerSelector() {
    return GestureDetector(
      onTap: selectRetailer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.divider),
          boxShadow: const [
            BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: _C.indigo,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedBuyerName.isEmpty
                    ? 'Select Retailer'
                    : selectedBuyerName,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selectedBuyerName.isEmpty
                      ? _C.textSub
                      : _C.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _C.indigo,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateFilterRow() {
    final dateOptions = [
      {'key': 'all', 'label': 'All Time'},
      {'key': 'today', 'label': 'Today'},
      {'key': 'week', 'label': 'This Week'},
      {'key': 'month', 'label': 'This Month'},
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dateOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = dateOptions[i];
          final sel = _dateFilter == opt['key'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _dateFilter = opt['key']!;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? _C.indigo : _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? _C.indigo : _C.divider),
                boxShadow: [
                  BoxShadow(
                    color: sel ? _C.indigo.withValues(alpha: 0.2) : _C.shadow,
                    blurRadius: sel ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  opt['label']!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : _C.textSub,
                  ),
                ),
              ),
            ),
          );
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
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search by invoice number, amount, date...',
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
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(
                    Icons.close_rounded,
                    color: _C.textSub,
                    size: 18,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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
        color: _C.divider,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          _skeletonBox(width: 46, height: 46, radius: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 120, height: 14),
                const SizedBox(height: 8),
                _skeletonBox(width: 80, height: 11),
                const SizedBox(height: 8),
                _skeletonBox(width: 100, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _skeletonBox(width: 70, height: 20, radius: 8),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return _BlinkingSkeleton(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => _skeletonCard(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              child: Icon(icon, size: 38, color: _C.indigo),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: _C.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showButton) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: selectRetailer,
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text("Select Retailer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildCard(Map<String, dynamic> invoice) {
    final int id = invoice["invoice_id"] ?? 0;
    final String status =
        invoice["status"]?.toString().toLowerCase() ?? 'pending';
    final String invoiceNumber =
        invoice["invoice_number"]?.toString() ?? 'Unknown';
    final String amount = invoice["total_amount"]?.toString() ?? '0';
    final String date = formatDate(invoice["invoice_date"]?.toString());
    final Color statusColor = getStatusColor(status);
    final Color statusBg = getStatusBgColor(status);
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: id == 0
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceDetailScreen(invoiceId: id),
                      ),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          invoiceNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: _C.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹ $amount",
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: _C.textSub,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: _C.textSub,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: _C.indigoSoft,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: _C.indigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final hp = _hPad(width);
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Invoice List',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_sectionLabel('Retailer'), _retailerSelector()],
                ),
              ),
              Expanded(
                child: selectedBuyerId == null
                    ? _buildEmptyState(
                        icon: Icons.storefront_rounded,
                        title: "No Retailer Selected",
                        subtitle:
                            "Please select a retailer from the top to view their invoices.",
                        showButton: true,
                      )
                    : isLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: hp),
                        child: _buildSkeletonList(),
                      )
                    : invoices.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: "No Invoices Found",
                        subtitle:
                            "There are no invoices generated for this retailer yet.",
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _sectionLabel('Search'),
                                _searchField(),
                                const SizedBox(height: 14),
                                _sectionLabel('Date Filter'),
                                _dateFilterRow(),
                                const SizedBox(height: 14),
                                Row(
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
                                      'Results',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _C.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: _C.indigoSoft,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        '${filtered.length}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _C.indigo,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Expanded(
                            child: filtered.isEmpty
                                ? _buildEmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: "No Matching Invoices",
                                    subtitle:
                                        "No invoices matched your search query or date filters.",
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: hp,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) =>
                                        buildCard(filtered[i]),
                                  ),
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
}

class _RetailerBottomSheet extends StatefulWidget {
  final List buyers;
  final int? selectedBuyerId;
  const _RetailerBottomSheet({required this.buyers, this.selectedBuyerId});
  @override
  State<_RetailerBottomSheet> createState() => _RetailerBottomSheetState();
}

class _RetailerBottomSheetState extends State<_RetailerBottomSheet> {
  late final TextEditingController _searchController;
  late final ValueNotifier<List<Map<String, dynamic>>> _filteredNotifier;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredNotifier = ValueNotifier(
      List<Map<String, dynamic>>.from(widget.buyers),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _C.indigo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Retailer',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: _C.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search retailer...',
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        final query = value.toLowerCase().trim();
                        _filteredNotifier.value = widget.buyers
                            .where(
                              (e) => e["name"]
                                  .toString()
                                  .toLowerCase()
                                  .contains(query),
                            )
                            .toList()
                            .cast<Map<String, dynamic>>();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _filteredNotifier,
                      builder: (context, filtered, _) {
                        if (filtered.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No retailer found',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: _C.textSub,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final id =
                                int.tryParse(
                                  item["user_id"]?.toString() ?? '',
                                ) ??
                                0;
                            final isSelected =
                                widget.selectedBuyerId != null &&
                                id == widget.selectedBuyerId;
                            final name = item["name"]?.toString() ?? 'Store';
                            final initial = name.isNotEmpty
                                ? name[0].toUpperCase()
                                : 'S';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.of(context).pop(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _C.indigoSoft
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? _C.indigo
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _C.indigo
                                                : _C.slateSoft,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : _C.slate,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? _C.indigo
                                                  : _C.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: _C.indigo,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
