import 'package:drug_tracking_system/core/services/api_service/invoice_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const slate = Color(0xFF475569);
  static const slateSoft = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String status = "pending";
  @override
  void initState() {
    super.initState();
    loadDetails();
  }
  Future<void> loadDetails() async {
    try {
      final res = await InvoiceApi.getInvoiceDetails(widget.invoiceId);
      if (!mounted) return;

      final rawItems = (res["items"] as List? ?? []);
      final parsed = rawItems.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          "drug_name": m["drug_name"]?.toString() ?? "",
          "batch_no": m["batch_no"]?.toString() ?? "",
          "quantity": int.tryParse(m["quantity"]?.toString() ?? "0") ?? 0,
          "price": double.tryParse(m["selling_price"]?.toString() ?? "0") ?? 0.0,
          "total": double.tryParse(m["total"]?.toString() ?? "0") ?? 0.0,
        };
      }).toList();

      final invoiceMap = res["invoice"] as Map<String, dynamic>? ?? {};

      setState(() {
        items = parsed;
        status = invoiceMap["status"]?.toString().toLowerCase() ?? "pending";
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Color getStatusColor() {
    switch (status) {
      case "accepted":
        return _C.green;
      case "rejected":
        return _C.rose;
      default:
        return _C.amber;
    }
  }

  Color getStatusBgColor() {
    switch (status) {
      case "accepted":
        return _C.greenSoft;
      case "rejected":
        return _C.roseSoft;
      default:
        return _C.amberSoft;
    }
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

  Widget buildItem(Map<String, dynamic> item) {
    final String drugName = item["drug_name"] ?? "";
    final String batchNo = item["batch_no"] ?? "";
    final int quantity = item["quantity"] ?? 0;
    final double price = item["price"] ?? 0.0;
    final double total = item["total"] ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: _C.indigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drugName,
                  style: GoogleFonts.nunito(
                    color: _C.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Batch: $batchNo",
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: $quantity  •  Price: ₹$price",
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "₹$total",
            style: GoogleFonts.nunito(
              color: _C.indigo,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  double getTotal() {
    double sum = 0;
    for (var e in items) {
      sum += (e["total"] as double? ?? 0.0);
    }
    return sum;
  }

  Widget _buildSummaryCard() {
    final Color statusColor = getStatusColor();
    final Color statusBg = getStatusBgColor();
    final int totalQty = items.fold<int>(
      0,
      (sum, item) => sum + (item["quantity"] as int? ?? 0),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: _C.indigoSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_rounded,
              color: _C.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invoice #${widget.invoiceId}",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Status: ",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.textSub,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
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
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Total Items: ${items.length}  •  Total Qty: $totalQty",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBreakdownCard() {
    final double totalAmount = getTotal();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textSub,
                ),
              ),
              Text(
                "₹$totalAmount",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: _C.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
              Text(
                "₹$totalAmount",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _C.indigo,
                ),
              ),
            ],
          ),
        ],
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

  Widget _skeletonItemCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
      ),
      child: Row(
        children: [
          _skeletonBox(width: 44, height: 44, radius: 12),
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
          _skeletonBox(width: 60, height: 16, radius: 6),
        ],
      ),
    );
  }

  Widget _buildSkeletonDetails() {
    return _BlinkingSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.divider),
            ),
            child: Row(
              children: [
                _skeletonBox(width: 50, height: 50, radius: 25),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(width: 100, height: 16),
                      const SizedBox(height: 8),
                      _skeletonBox(width: 80, height: 12),
                      const SizedBox(height: 8),
                      _skeletonBox(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _skeletonBox(width: 100, height: 18),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (_, __) => _skeletonItemCard(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final hp = _hPad(width);
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Invoice Details',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
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
        child: isLoading
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: _buildSkeletonDetails(),
              )
            : items.isEmpty
            ? Center(
                child: Text(
                  "No Data Found",
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Summary'),
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    _sectionLabel('Invoice Items'),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, i) => buildItem(items[i]),
                    ),
                    const SizedBox(height: 10),
                    _sectionLabel('Amount Details'),
                    _buildTotalBreakdownCard(),
                    const SizedBox(height: 20),
                  ],
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
