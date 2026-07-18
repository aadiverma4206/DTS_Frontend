import 'package:drug_tracking_system/core/services/api_service/invoice_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum InvoiceFilter { all, info, wholesaler, retailer, drugs, summary }

enum DrugSort {
  none,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  qtyAsc,
  qtyDesc,
  expiryAsc,
  expiryDesc,
}

class _C {
  static const bg = Color(0xFFF4F2FB);
  static const surface = Color(0xFFFFFFFF);
  static const purple = Color(0xFF8640F6);
  static const purpleSoft = Color(0xFFEDE8FB);
  static const textPrimary = Color(0xFF1A1035);
  static const textSub = Color(0xFF7B7494);
  static const divider = Color(0xFFE5E0F5);
  static const shadow = Color(0x14602EE8);
  static const accept = Color(0xFF00B87A);
  static const acceptBg = Color(0xFFE6F9F2);
  static const reject = Color(0xFFE8455A);
  static const rejectBg = Color(0xFFFDECEF);
  static const pending = Color(0xFFF59E0B);
  static const pendingBg = Color(0xFFFFF8EC);
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFEFF6FF);
  static const shimmer = Color(0xFFDDD8F0);
}

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> invoice = {};
  Map<String, dynamic> wholesaler = {};
  Map<String, dynamic> retailer = {};
  Map<String, dynamic> summary = {};
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredDrugs = [];

  bool isLoading = true;
  bool isProcessing = false;
  String status = 'pending';

  InvoiceFilter activeFilter = InvoiceFilter.all;
  final TextEditingController _searchCtrl = TextEditingController();
  String searchQuery = '';

  DrugSort drugSort = DrugSort.none;
  double? drugMinPrice;
  double? drugMaxPrice;
  int? drugMinQty;
  int? drugMaxQty;
  bool? filterNarcotic;
  bool? filterExpired;
  bool? filterExpiringSoon;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  String _v(dynamic x) =>
      x == null || x.toString().trim().isEmpty ? '' : x.toString();

  String _fmtDate(String? v) {
    if (v == null || v.trim().isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  String _fmtDateTime(String? v) {
    if (v == null || v.trim().isEmpty) return '—';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  Color get _statusColor => status == 'accepted'
      ? _C.accept
      : status == 'rejected'
      ? _C.reject
      : _C.pending;

  Color get _statusBg => status == 'accepted'
      ? _C.acceptBg
      : status == 'rejected'
      ? _C.rejectBg
      : _C.pendingBg;

  IconData get _statusIcon => status == 'accepted'
      ? Icons.check_circle_rounded
      : status == 'rejected'
      ? Icons.cancel_rounded
      : Icons.access_time_rounded;

  double get grandTotal =>
      allItems.fold(0.0, (s, e) => s + (e['total'] as num).toDouble());

  bool get _hasDrugFilter =>
      drugSort != DrugSort.none ||
      drugMinPrice != null ||
      drugMaxPrice != null ||
      drugMinQty != null ||
      drugMaxQty != null ||
      filterNarcotic != null ||
      filterExpired != null ||
      filterExpiringSoon != null;

  bool get isProcessed => status == 'accepted' || status == 'rejected';

  List<Map<String, dynamic>> get _allSections => [
    {
      'filter': InvoiceFilter.info,
      'label': 'Invoice Info',
      'icon': Icons.receipt_long_rounded,
      'color': _C.purple,
      'fields': [
        {'title': 'Invoice No', 'value': _v(invoice['invoice_number'])},
        {
          'title': 'Invoice Date',
          'value': _fmtDate(_v(invoice['invoice_date'])),
        },
        {
          'title': 'Received At',
          'value': _fmtDateTime(_v(invoice['created_at'])),
        },
        {'title': 'Status', 'value': _v(invoice['status'])},
      ],
    },
    {
      'filter': InvoiceFilter.wholesaler,
      'label': 'Wholesaler (From)',
      'icon': Icons.store_rounded,
      'color': _C.purple,
      'fields': [
        {'title': 'Name', 'value': _v(wholesaler['name'])},
        {'title': 'Shop', 'value': _v(wholesaler['shop_name'])},
        {'title': 'DL No', 'value': _v(wholesaler['dl_no'])},
        {'title': 'GSTIN', 'value': _v(wholesaler['gstin'])},
        {'title': 'Phone', 'value': _v(wholesaler['phone'])},
        {'title': 'Email', 'value': _v(wholesaler['email'])},
        {'title': 'Address', 'value': _v(wholesaler['address'])},
      ],
    },
    {
      'filter': InvoiceFilter.retailer,
      'label': 'Retailer (To)',
      'icon': Icons.storefront_rounded,
      'color': _C.info,
      'fields': [
        {'title': 'Name', 'value': _v(retailer['name'])},
        {'title': 'Shop', 'value': _v(retailer['shop_name'])},
        {'title': 'DL No', 'value': _v(retailer['dl_no'])},
        {'title': 'GSTIN', 'value': _v(retailer['gstin'])},
        {'title': 'Phone', 'value': _v(retailer['phone'])},
        {'title': 'Email', 'value': _v(retailer['email'])},
        {'title': 'Address', 'value': _v(retailer['address'])},
      ],
    },
    {
      'filter': InvoiceFilter.summary,
      'label': 'Summary',
      'icon': Icons.summarize_rounded,
      'color': _C.accept,
      'fields': [
        {'title': 'Total Items', 'value': _v(summary['total_items'])},
        {'title': 'Total Quantity', 'value': _v(summary['total_quantity'])},
        {'title': 'Grand Total', 'value': '₹${grandTotal.toStringAsFixed(2)}'},
      ],
    },
  ];

  List<Map<String, dynamic>> get _visibleSections {
    return _allSections.where((section) {
      if (activeFilter == InvoiceFilter.drugs) return false;
      if (activeFilter != InvoiceFilter.all &&
          section['filter'] != activeFilter)
        return false;
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

  void _applyDrugFilters() {
    if (activeFilter != InvoiceFilter.all &&
        activeFilter != InvoiceFilter.drugs) {
      filteredDrugs = [];
      return;
    }
    final q = searchQuery.toLowerCase();
    List<Map<String, dynamic>> result = allItems.where((item) {
      if (q.isNotEmpty) {
        final nameMatch =
            item['drug_name'].toString().toLowerCase().contains(q) ||
            item['batch_no'].toString().toLowerCase().contains(q) ||
            item['composition'].toString().toLowerCase().contains(q) ||
            item['category'].toString().toLowerCase().contains(q);
        if (!nameMatch) return false;
      }
      final price = item['selling_price'] as double;
      if (drugMinPrice != null && price < drugMinPrice!) return false;
      if (drugMaxPrice != null && price > drugMaxPrice!) return false;
      final qty = item['quantity'] as int;
      if (drugMinQty != null && qty < drugMinQty!) return false;
      if (drugMaxQty != null && qty > drugMaxQty!) return false;
      if (filterNarcotic == true && !(item['is_narcotic'] as bool))
        return false;
      DateTime? expiry;
      try {
        expiry = DateTime.parse(item['expiry_date'].toString());
      } catch (_) {}
      final isExpired = expiry != null && expiry.isBefore(DateTime.now());
      final isExpiringSoon =
          expiry != null &&
          !isExpired &&
          expiry.difference(DateTime.now()).inDays <= 90;
      if (filterExpired == true && !isExpired) return false;
      if (filterExpiringSoon == true && !isExpiringSoon) return false;
      return true;
    }).toList();

    switch (drugSort) {
      case DrugSort.nameAsc:
        result.sort(
          (a, b) =>
              a['drug_name'].toString().compareTo(b['drug_name'].toString()),
        );
        break;
      case DrugSort.nameDesc:
        result.sort(
          (a, b) =>
              b['drug_name'].toString().compareTo(a['drug_name'].toString()),
        );
        break;
      case DrugSort.priceAsc:
        result.sort(
          (a, b) => (a['selling_price'] as double).compareTo(
            b['selling_price'] as double,
          ),
        );
        break;
      case DrugSort.priceDesc:
        result.sort(
          (a, b) => (b['selling_price'] as double).compareTo(
            a['selling_price'] as double,
          ),
        );
        break;
      case DrugSort.qtyAsc:
        result.sort(
          (a, b) => (a['quantity'] as int).compareTo(b['quantity'] as int),
        );
        break;
      case DrugSort.qtyDesc:
        result.sort(
          (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
        );
        break;
      case DrugSort.expiryAsc:
        result.sort((a, b) {
          try {
            return DateTime.parse(
              a['expiry_date'],
            ).compareTo(DateTime.parse(b['expiry_date']));
          } catch (_) {
            return 0;
          }
        });
        break;
      case DrugSort.expiryDesc:
        result.sort((a, b) {
          try {
            return DateTime.parse(
              b['expiry_date'],
            ).compareTo(DateTime.parse(a['expiry_date']));
          } catch (_) {
            return 0;
          }
        });
        break;
      default:
        break;
    }
    filteredDrugs = result;
  }

  void _clearDrugFilters() {
    setState(() {
      drugSort = DrugSort.none;
      drugMinPrice = null;
      drugMaxPrice = null;
      drugMinQty = null;
      drugMaxQty = null;
      filterNarcotic = null;
      filterExpired = null;
      filterExpiringSoon = null;
      _applyDrugFilters();
    });
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _searchCtrl.addListener(() {
      setState(() {
        searchQuery = _searchCtrl.text.toLowerCase().trim();
        _applyDrugFilters();
      });
    });
    _loadDetails();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() => isLoading = true);
    try {
      final dynamic res = await InvoiceApi.getInvoiceDetails(widget.invoiceId);
      if (!mounted) return;
      if (res is Map<String, dynamic> && res['success'] == true) {
        final inv = Map<String, dynamic>.from(res['invoice'] ?? {});
        final ws = Map<String, dynamic>.from(res['wholesaler'] ?? {});
        final rt = Map<String, dynamic>.from(res['retailer'] ?? {});
        final sm = Map<String, dynamic>.from(res['summary'] ?? {});
        final rawItems = res['items'] is List ? res['items'] as List : [];
        final parsed = rawItems.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final qty = int.tryParse(m['quantity']?.toString() ?? '0') ?? 0;
          final price =
              double.tryParse(m['selling_price']?.toString() ?? '0') ?? 0.0;
          final mrp = double.tryParse(m['mrp']?.toString() ?? '0') ?? 0.0;
          final purchasePrice =
              double.tryParse(m['purchase_price']?.toString() ?? '0') ?? 0.0;
          return {
            'item_id': m['item_id'],
            'drug_name': m['drug_name']?.toString() ?? '',
            'composition': m['composition']?.toString() ?? '',
            'category': m['category']?.toString() ?? '',
            'strength': m['strength']?.toString() ?? '',
            'dosage_form': m['dosage_form']?.toString() ?? '',
            'is_narcotic': m['is_narcotic'] == 1 || m['is_narcotic'] == true,
            'batch_no': m['batch_no']?.toString() ?? '',
            'manufacture_date': m['manufacture_date']?.toString() ?? '',
            'expiry_date': m['expiry_date']?.toString() ?? '',
            'quantity': qty,
            'selling_price': price,
            'mrp': mrp,
            'purchase_price': purchasePrice,
            'total': (qty * price).toDouble(),
            'manufacturer_name': m['manufacturer_name']?.toString() ?? '',
            'manufacturer_dl_no': m['manufacturer_dl_no']?.toString() ?? '',
            'manufacturer_phone': m['manufacturer_phone']?.toString() ?? '',
          };
        }).toList();
        setState(() {
          invoice = inv;
          wholesaler = ws;
          retailer = rt;
          summary = sm;
          allItems = parsed;
          status = inv['status']?.toString().toLowerCase() ?? 'pending';
          isLoading = false;
          _applyDrugFilters();
        });
        _fadeCtrl.forward(from: 0);
      } else {
        throw Exception(res['message'] ?? 'Failed to load invoice details');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.reject,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (isProcessing) return;
    final bool confirmed = await _showConfirmDialog(newStatus);
    if (!confirmed) return;
    setState(() => isProcessing = true);
    try {
      final msg = await InvoiceApi.updateInvoiceStatus(
        invoiceId: widget.invoiceId,
        status: newStatus,
      );
      if (!mounted) return;
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.accept,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        borderRadius: 12,
      );
      await _loadDetails();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('Already processed') ||
          msg.contains('already processed')) {
        await _loadDetails();
      }
      Get.snackbar(
        'Error',
        msg.replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.reject,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<bool> _showConfirmDialog(String newStatus) async {
    final isAccept = newStatus == 'accepted';
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _C.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isAccept ? _C.acceptBg : _C.rejectBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isAccept ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isAccept ? _C.accept : _C.reject,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isAccept ? 'Accept Invoice?' : 'Reject Invoice?',
                style: GoogleFonts.nunito(
                  color: _C.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAccept
                    ? 'This will accept the invoice and update your inventory accordingly.'
                    : 'This will reject the invoice. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: _C.textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _C.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _C.divider),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(
                              color: _C.textSub,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isAccept ? _C.accept : _C.reject,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (isAccept ? _C.accept : _C.reject)
                                  .withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isAccept ? 'Accept' : 'Reject',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.22;
    if (w > 900) return w * 0.14;
    if (w > 600) return w * 0.07;
    return 16;
  }

  Widget _shimmerBox({
    double width = double.infinity,
    double height = 14,
    double radius = 8,
  }) => _ShimmerBox(width: width, height: height, radius: radius);

  Widget _skeletonHeroCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.purpleSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _shimmerBox(width: 52, height: 52, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 160, height: 18),
                const SizedBox(height: 8),
                _shimmerBox(width: 100, height: 13),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _shimmerBox(width: 70, height: 26, radius: 8),
        ],
      ),
    );
  }

  Widget _skeletonSection(Color headerColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
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
              color: headerColor.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _shimmerBox(width: 40, height: 40, radius: 12),
                const SizedBox(width: 12),
                _shimmerBox(width: 120, height: 15),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      _shimmerBox(width: 100, height: 13),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(height: 13)),
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

  Widget _skeletonDrugCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
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
                      _shimmerBox(width: 160, height: 15),
                      const SizedBox(height: 6),
                      _shimmerBox(width: 120, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                    3,
                    (_) => _shimmerBox(width: 60, height: 22, radius: 20),
                  ),
                ),
                const SizedBox(height: 12),
                _shimmerBox(height: 80, radius: 12),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _shimmerBox(height: 60, radius: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmerBox(height: 60, radius: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: _shimmerBox(height: 60, radius: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                _shimmerBox(height: 46, radius: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.nunito(
              color: _C.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, InvoiceFilter filter, Color activeColor) {
    final sel = activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() {
        activeFilter = filter;
        _applyDrugFilters();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? activeColor : _C.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: sel ? activeColor : _C.divider, width: 1.5),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: sel ? Colors.white : _C.textSub,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    final q = searchQuery;
    final matchesSearch =
        q.isNotEmpty &&
        (value.toLowerCase().contains(q) || title.toLowerCase().contains(q));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: GoogleFonts.nunito(
                color: _C.textSub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
                      color: _C.purple.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                value.isEmpty ? '—' : value,
                style: GoogleFonts.nunito(
                  color: _C.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.divider),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
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
                    style: GoogleFonts.nunito(
                      color: _C.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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

  Widget _badge(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor.withOpacity(0.8)),
        const SizedBox(width: 7),
        Text(
          '$label: ',
          style: GoogleFonts.nunito(
            color: _C.textSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.nunito(
              color: _C.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _priceBox(
    String label,
    String value,
    Color color,
    Color bg,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: _C.textSub,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> item) {
    final isNarcotic = item['is_narcotic'] as bool;
    DateTime? expiry;
    try {
      expiry = DateTime.parse(item['expiry_date'].toString());
    } catch (_) {}
    final isExpired = expiry != null && expiry.isBefore(DateTime.now());
    final isExpiringSoon =
        expiry != null &&
        !isExpired &&
        expiry.difference(DateTime.now()).inDays <= 90;
    final drugName = item['drug_name'].toString();
    final q = searchQuery;
    final matchesSearch = q.isNotEmpty && drugName.toLowerCase().contains(q);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpired
                ? _C.reject.withOpacity(0.3)
                : isExpiringSoon
                ? _C.pending.withOpacity(0.3)
                : matchesSearch
                ? _C.purple.withOpacity(0.3)
                : _C.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: matchesSearch
                    ? _C.purple.withOpacity(0.10)
                    : _C.purpleSoft,
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
                      color: _C.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: _C.purple,
                      size: 22,
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
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((item['composition'] as String).isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['composition'],
                            style: GoogleFonts.nunito(
                              color: _C.textSub,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if ((item['category'] as String).isNotEmpty)
                        _badge(item['category'], _C.info, _C.infoBg),
                      if ((item['dosage_form'] as String).isNotEmpty)
                        _badge(item['dosage_form'], _C.purple, _C.purpleSoft),
                      if ((item['strength'] as String).isNotEmpty)
                        _badge(item['strength'], _C.pending, _C.pendingBg),
                      if (isNarcotic)
                        _badge('NARCOTIC', _C.reject, _C.rejectBg),
                      if (isExpired) _badge('EXPIRED', _C.reject, _C.rejectBg),
                      if (isExpiringSoon && !isExpired)
                        _badge('EXPIRING SOON', _C.pending, _C.pendingBg),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _C.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.divider),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          Icons.qr_code_rounded,
                          'Batch No',
                          item['batch_no'],
                          _C.purple,
                        ),
                        const SizedBox(height: 6),
                        _detailRow(
                          Icons.factory_rounded,
                          'Mfg Date',
                          _fmtDate(item['manufacture_date']),
                          _C.info,
                        ),
                        const SizedBox(height: 6),
                        _detailRow(
                          Icons.event_rounded,
                          'Expiry',
                          _fmtDate(item['expiry_date']),
                          isExpired
                              ? _C.reject
                              : isExpiringSoon
                              ? _C.pending
                              : _C.accept,
                        ),
                        if ((item['manufacturer_name'] as String)
                            .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _detailRow(
                            Icons.business_rounded,
                            'Manufacturer',
                            item['manufacturer_name'],
                            _C.textSub,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _priceBox(
                          'Selling Price',
                          '₹${(item['selling_price'] as double).toStringAsFixed(2)}',
                          _C.pending,
                          _C.pendingBg,
                          Icons.sell_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _priceBox(
                          'MRP',
                          '₹${(item['mrp'] as double).toStringAsFixed(2)}',
                          _C.info,
                          _C.infoBg,
                          Icons.price_change_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _priceBox(
                          'Quantity',
                          item['quantity'].toString(),
                          _C.purple,
                          _C.purpleSoft,
                          Icons.inventory_2_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _C.acceptBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _C.accept.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Item Total',
                          style: GoogleFonts.nunito(
                            color: _C.textSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${(item['total'] as double).toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            color: _C.accept,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDrugFilterSheet() {
    final minPriceCtrl = TextEditingController(
      text: drugMinPrice?.toString() ?? '',
    );
    final maxPriceCtrl = TextEditingController(
      text: drugMaxPrice?.toString() ?? '',
    );
    final minQtyCtrl = TextEditingController(
      text: drugMinQty?.toString() ?? '',
    );
    final maxQtyCtrl = TextEditingController(
      text: drugMaxQty?.toString() ?? '',
    );
    DrugSort tempSort = drugSort;
    bool? tempNarcotic = filterNarcotic;
    bool? tempExpired = filterExpired;
    bool? tempExpiringSoon = filterExpiringSoon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Filter & Sort Drugs',
                      style: GoogleFonts.nunito(
                        color: _C.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _clearDrugFilters();
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.nunito(
                          color: _C.reject,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'SORT BY',
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _sheetSortChip(
                      'Name A→Z',
                      DrugSort.nameAsc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Name Z→A',
                      DrugSort.nameDesc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Price ↑',
                      DrugSort.priceAsc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Price ↓',
                      DrugSort.priceDesc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Qty ↑',
                      DrugSort.qtyAsc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Qty ↓',
                      DrugSort.qtyDesc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Expiry ↑',
                      DrugSort.expiryAsc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                    _sheetSortChip(
                      'Expiry ↓',
                      DrugSort.expiryDesc,
                      tempSort,
                      (v) => setSheet(() => tempSort = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'PRICE RANGE (₹)',
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _sheetField(
                        minPriceCtrl,
                        'Min Price',
                        TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _sheetField(
                        maxPriceCtrl,
                        'Max Price',
                        TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'QUANTITY RANGE',
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _sheetField(
                        minQtyCtrl,
                        'Min Qty',
                        TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _sheetField(
                        maxQtyCtrl,
                        'Max Qty',
                        TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'DRUG TYPE & STATUS',
                  style: GoogleFonts.nunito(
                    color: _C.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _sheetToggleChip(
                      'Narcotic Only',
                      Icons.warning_amber_rounded,
                      tempNarcotic == true,
                      _C.reject,
                      _C.rejectBg,
                      () => setSheet(
                        () => tempNarcotic = tempNarcotic == true ? null : true,
                      ),
                    ),
                    _sheetToggleChip(
                      'Expired',
                      Icons.event_busy_rounded,
                      tempExpired == true,
                      _C.reject,
                      _C.rejectBg,
                      () => setSheet(
                        () => tempExpired = tempExpired == true ? null : true,
                      ),
                    ),
                    _sheetToggleChip(
                      'Expiring Soon',
                      Icons.hourglass_bottom_rounded,
                      tempExpiringSoon == true,
                      _C.pending,
                      _C.pendingBg,
                      () => setSheet(
                        () => tempExpiringSoon = tempExpiringSoon == true
                            ? null
                            : true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        drugSort = tempSort;
                        drugMinPrice = double.tryParse(
                          minPriceCtrl.text.trim(),
                        );
                        drugMaxPrice = double.tryParse(
                          maxPriceCtrl.text.trim(),
                        );
                        drugMinQty = int.tryParse(minQtyCtrl.text.trim());
                        drugMaxQty = int.tryParse(maxQtyCtrl.text.trim());
                        filterNarcotic = tempNarcotic;
                        filterExpired = tempExpired;
                        filterExpiringSoon = tempExpiringSoon;
                        _applyDrugFilters();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
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

  Widget _sheetSortChip(
    String label,
    DrugSort value,
    DrugSort current,
    void Function(DrugSort) onTap,
  ) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(sel ? DrugSort.none : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _C.purple : _C.bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: sel ? _C.purple : _C.divider, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: sel ? Colors.white : _C.textSub,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _sheetToggleChip(
    String label,
    IconData icon,
    bool sel,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color : _C.bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: sel ? color : _C.divider, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: sel ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: sel ? Colors.white : _C.textSub,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    TextInputType type,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.divider, width: 1.2),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: GoogleFonts.nunito(color: _C.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: _C.textSub, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = _hPad;
    final canPop = Navigator.of(context).canPop();
    final showDrugs =
        activeFilter == InvoiceFilter.all ||
        activeFilter == InvoiceFilter.drugs;
    final visibleSections = _visibleSections;

    return Scaffold(
      backgroundColor: _C.bg,
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
          'Invoice Details',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(height: 24, color: _C.bg),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: _C.surface,
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _C.bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.divider, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: _C.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.nunito(
                          color: _C.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search field name or value...',
                          hintStyle: GoogleFonts.nunito(
                            color: _C.textSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _C.purple.withOpacity(0.7),
                            size: 20,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() {
                                      searchQuery = '';
                                      _applyDrugFilters();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: _C.textSub,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _filterChip('All', InvoiceFilter.all, _C.purple),
                          const SizedBox(width: 8),
                          _filterChip('Drugs', InvoiceFilter.drugs, _C.reject),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Invoice Info',
                            InvoiceFilter.info,
                            _C.purple,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Wholesaler',
                            InvoiceFilter.wholesaler,
                            _C.purple,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Retailer',
                            InvoiceFilter.retailer,
                            _C.info,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Summary',
                            InvoiceFilter.summary,
                            _C.accept,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: _C.divider),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isLoading
                                ? 'Loading...'
                                : activeFilter == InvoiceFilter.drugs
                                ? '${filteredDrugs.length} of ${allItems.length} drugs'
                                : activeFilter == InvoiceFilter.all
                                ? '${visibleSections.length} sections • ${filteredDrugs.length}/${allItems.length} drugs'
                                : '${visibleSections.length} sections',
                            style: GoogleFonts.nunito(
                              color: _C.textSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (showDrugs)
                          GestureDetector(
                            onTap: _showDrugFilterSheet,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _hasDrugFilter ? _C.purple : _C.bg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _hasDrugFilter
                                      ? _C.purple
                                      : _C.divider,
                                  width: 1.2,
                                ),
                                boxShadow: _hasDrugFilter
                                    ? [
                                        BoxShadow(
                                          color: _C.purple.withOpacity(0.22),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 14,
                                    color: _hasDrugFilter
                                        ? Colors.white
                                        : _C.textSub,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _hasDrugFilter
                                        ? 'Filtered'
                                        : 'Filter Drugs',
                                    style: GoogleFonts.nunito(
                                      color: _hasDrugFilter
                                          ? Colors.white
                                          : _C.textSub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_hasDrugFilter) ...[
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: _clearDrugFilters,
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
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
                child: isLoading
                    ? CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hp, 14, hp, 30),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _skeletonHeroCard(),
                                _skeletonSection(_C.purple),
                                _skeletonSection(_C.purple),
                                _skeletonSection(_C.info),
                                _skeletonSection(_C.accept),
                                _sectionLabel('Drug List', _C.reject),
                                _skeletonDrugCard(),
                                _skeletonDrugCard(),
                              ]),
                            ),
                          ),
                        ],
                      )
                    : (visibleSections.isEmpty &&
                          (!showDrugs || filteredDrugs.isEmpty))
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: _C.purpleSoft,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 40,
                                    color: _C.purple.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: GoogleFonts.nunito(
                                    color: _C.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: GoogleFonts.nunito(
                                    color: _C.textSub,
                                    fontSize: 13,
                                  ),
                                ),
                                if (_hasDrugFilter) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _clearDrugFilters,
                                    child: Text(
                                      'Clear drug filters',
                                      style: GoogleFonts.nunito(
                                        color: _C.purple,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        color: _C.purple,
                        backgroundColor: _C.surface,
                        onRefresh: _loadDetails,
                        child: CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(hp, 14, hp, 30),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  if (activeFilter == InvoiceFilter.all &&
                                      searchQuery.isEmpty)
                                    FadeTransition(
                                      opacity: _fadeAnim,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              _C.purple,
                                              Color(0xFF602EE8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _C.purple.withOpacity(
                                                0.35,
                                              ),
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
                                                color: Colors.white.withOpacity(
                                                  0.18,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.receipt_long_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _v(invoice['invoice_number'])
                                                            .isEmpty
                                                        ? 'Invoice'
                                                        : _v(invoice['invoice_number']),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.nunito(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _fmtDate(
                                                      _v(
                                                        invoice['invoice_date'],
                                                      ),
                                                    ),
                                                    style: GoogleFonts.nunito(
                                                      color: Colors.white70,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor.withOpacity(
                                                  0.18,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _statusIcon,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    status.toUpperCase(),
                                                    style: GoogleFonts.nunito(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ...visibleSections.map(_buildSection),
                                  if (showDrugs) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _C.reject.withOpacity(
                                                0.13,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.medication_rounded,
                                              color: _C.reject,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Drug List',
                                            style: GoogleFonts.nunito(
                                              color: _C.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _C.purpleSoft,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${filteredDrugs.length}/${allItems.length}',
                                              style: GoogleFonts.nunito(
                                                color: _C.purple,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (filteredDrugs.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 32,
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.medication_outlined,
                                                size: 40,
                                                color: _C.purple.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'No drugs match your filter',
                                                style: GoogleFonts.nunito(
                                                  color: _C.textSub,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: _clearDrugFilters,
                                                child: Text(
                                                  'Clear filters',
                                                  style: GoogleFonts.nunito(
                                                    color: _C.purple,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      ...filteredDrugs.map(_buildDrugCard),
                                  ],
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              Container(
                color: _C.surface,
                padding: EdgeInsets.fromLTRB(hp, 14, hp, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 1, color: _C.divider),
                    const SizedBox(height: 12),
                    isLoading
                        ? _shimmerBox(height: 64, radius: 18)
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _C.purple,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.purple.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GRAND TOTAL',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${allItems.length} item${allItems.length != 1 ? 's' : ''}',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '₹${grandTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    if (!isLoading && !isProcessed) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: isProcessing
                                  ? null
                                  : () => _updateStatus('rejected'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isProcessing
                                      ? _C.reject.withOpacity(0.5)
                                      : _C.rejectBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _C.reject.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: isProcessing
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: _C.reject,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.close_rounded,
                                              color: _C.reject,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Reject',
                                              style: GoogleFonts.nunito(
                                                color: _C.reject,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: isProcessing
                                  ? null
                                  : () => _updateStatus('accepted'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isProcessing
                                      ? _C.accept.withOpacity(0.5)
                                      : _C.accept,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isProcessing
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: _C.accept.withOpacity(0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Accept',
                                              style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isLoading && isProcessed) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _statusColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_statusIcon, color: _statusColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              status == 'accepted'
                                  ? 'Invoice Accepted'
                                  : 'Invoice Rejected',
                              style: GoogleFonts.nunito(
                                color: _statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
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

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _C.shimmer,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
