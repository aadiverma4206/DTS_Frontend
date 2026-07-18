import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/services/api_service/inspection_api.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const teal = Color(0xFF0D9488);
  static const tealSoft = Color(0xFFCCFBF1);
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

class InspectionDetailScreen extends StatefulWidget {
  final int inspectionId;

  const InspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  int _filterIndex = 0;

  Map<String, dynamic>? _inspection;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _checks = [];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  final List<String> _filters = ['All', 'Drugs', 'Checks', 'Remarks'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shimmerAnim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
    _shimmerCtrl.repeat(reverse: true);

    _loadDetail();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await InspectionApi.getInspectionDetails(
        widget.inspectionId,
      );
      if (!mounted) return;
      setState(() {
        _inspection = data['data']?['inspection'];
        _items = List<Map<String, dynamic>>.from(data['data']?['items'] ?? []);
        _checks = List<Map<String, dynamic>>.from(
          data['data']?['checks'] ?? [],
        );
        _isLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  Map<String, dynamic> _statusMeta(String status) {
    switch (status) {
      case 'verified':
        return {
          'color': _C.green,
          'bg': _C.greenSoft,
          'icon': Icons.verified_rounded,
          'label': 'Verified',
        };
      case 'discrepancy':
        return {
          'color': _C.rose,
          'bg': _C.roseSoft,
          'icon': Icons.warning_amber_rounded,
          'label': 'Discrepancy',
        };
      case 'in_progress':
        return {
          'color': _C.blue,
          'bg': _C.blueSoft,
          'icon': Icons.timelapse_rounded,
          'label': 'In Progress',
        };
      case 'completed':
        return {
          'color': _C.purple,
          'bg': _C.purpleSoft,
          'icon': Icons.check_circle_rounded,
          'label': 'Completed',
        };
      case 'pending':
        return {
          'color': _C.amber,
          'bg': _C.amberSoft,
          'icon': Icons.pending_actions_rounded,
          'label': 'Pending',
        };
      case 'rejected':
        return {
          'color': _C.slate,
          'bg': _C.slateSoft,
          'icon': Icons.cancel_rounded,
          'label': 'Rejected',
        };
      default:
        return {
          'color': _C.slate,
          'bg': _C.slateSoft,
          'icon': Icons.info_rounded,
          'label': status,
        };
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  double get _hPad {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
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

  Widget _filterBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final sel = _filterIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? _C.indigo : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _filters[i],
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                      color: sel ? Colors.white : _C.textSub,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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

  Widget _skeletonLoader() {
    return FadeTransition(
      opacity: _shimmerAnim,
      child: ListView(
        padding: EdgeInsets.fromLTRB(_hPad, 14, _hPad, 30),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.divider),
              boxShadow: [
                BoxShadow(
                  color: _C.shadow,
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _skeletonBox(width: 48, height: 48, radius: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _skeletonBox(width: 160, height: 16),
                          const SizedBox(height: 8),
                          _skeletonBox(width: 100, height: 12),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _skeletonBox(width: 70, height: 28, radius: 10),
                        const SizedBox(height: 6),
                        _skeletonBox(width: 70, height: 28, radius: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _skeletonBox(height: 48, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _skeletonBox(width: 120, height: 18),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.divider),
                  boxShadow: [
                    BoxShadow(
                      color: _C.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _skeletonBox(width: 42, height: 42, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _skeletonBox(width: 130, height: 14),
                          const SizedBox(height: 8),
                          _skeletonBox(width: 90, height: 11),
                        ],
                      ),
                    ),
                    _skeletonBox(width: 70, height: 28, radius: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    final insp = _inspection!;
    final status = insp['status']?.toString() ?? '';
    final meta = _statusMeta(status);
    final statusColor = meta['color'] as Color;
    final statusBg = meta['bg'] as Color;
    final statusIcon = meta['icon'] as IconData;
    final statusLabel = meta['label'] as String;
    final totalSystem =
        int.tryParse(insp['total_system_qty']?.toString() ?? '0') ?? 0;
    final totalPhysical =
        int.tryParse(insp['total_physical_qty']?.toString() ?? '0') ?? 0;
    final mismatch = totalSystem != totalPhysical;
    final type = (insp['inspection_type'] ?? '').toString();
    final isRetailer = type == 'retailer';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insp['target_name']?.toString() ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: _C.textSub,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(insp['inspection_date']?.toString()),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: _C.textSub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (insp['inspector_name'] != null &&
                        insp['inspector_name'].toString().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 11,
                            color: _C.textSub,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              insp['inspector_name'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: _C.textSub,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (type.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isRetailer ? _C.greenSoft : _C.blueSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isRetailer ? _C.green : _C.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mismatch ? _C.roseSoft : _C.greenSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: mismatch ? _C.rose : _C.green),
            ),
            child: Row(
              children: [
                Icon(
                  mismatch
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: mismatch ? _C.rose : _C.green,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'System: $totalSystem  •  Physical: $totalPhysical  •  ${mismatch ? "Mismatch" : "Matched ✓"}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: mismatch ? _C.rose : _C.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drugItemCard(Map<String, dynamic> item) {
    final isMismatch = item['status'] == 'mismatch';
    final systemQty = int.tryParse(item['system_qty']?.toString() ?? '0') ?? 0;
    final physicalQty =
        int.tryParse(item['physical_qty']?.toString() ?? '0') ?? 0;
    final drugName = item['drug_name']?.toString() ?? '';
    final batchNo = item['batch_no']?.toString() ?? '';
    final diff = physicalQty - systemQty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMismatch ? _C.rose : _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isMismatch ? _C.roseSoft : _C.indigoSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: isMismatch ? _C.rose : _C.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drugName.isNotEmpty ? drugName : 'Unknown Drug',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                      if (batchNo.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.qr_code_rounded,
                              size: 11,
                              color: _C.textSub,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Batch: $batchNo',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: _C.textSub,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isMismatch ? _C.roseSoft : _C.greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMismatch
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        size: 11,
                        color: isMismatch ? _C.rose : _C.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMismatch ? 'Mismatch' : 'Matched',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isMismatch ? _C.rose : _C.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _qtyChip('System', systemQty, _C.blue, _C.blueSoft),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _qtyChip(
                    'Physical',
                    physicalQty,
                    isMismatch ? _C.rose : _C.green,
                    isMismatch ? _C.roseSoft : _C.greenSoft,
                  ),
                ),
                if (isMismatch) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _qtyChip('Diff', diff, _C.amber, _C.amberSoft),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyChip(String label, int value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '${value >= 0 ? "" : ""}$value',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkCard(Map<String, dynamic> check) {
    final value = check['check_value']?.toString() ?? 'no';
    final isYes = value == 'yes' || value == 'pass';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isYes ? _C.green : _C.rose),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isYes ? _C.greenSoft : _C.roseSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isYes ? Icons.verified_rounded : Icons.cancel_rounded,
              color: isYes ? _C.green : _C.rose,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              check['check_name']?.toString() ?? '',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isYes ? _C.greenSoft : _C.roseSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isYes ? 'Pass' : 'Fail',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isYes ? _C.green : _C.rose,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remarksCard() {
    final remarks = _inspection?['remarks']?.toString() ?? '';
    if (remarks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.divider),
          boxShadow: [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notes_rounded,
                color: _C.indigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'No remarks added',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: _C.textSub,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _C.indigoSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: _C.indigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Inspector Notes',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _C.textSub,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remarks,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
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
              Icons.assignment_late_rounded,
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
            'Inspection details could not be loaded',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: _C.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadDetail,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.indigo.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 16, color: _C.indigo),
                  const SizedBox(width: 6),
                  Text(
                    'Try Again',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final showDrugs = _filterIndex == 0 || _filterIndex == 1;
    final showChecks = _filterIndex == 0 || _filterIndex == 2;
    final showRemarks = _filterIndex == 0 || _filterIndex == 3;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 30),
        children: [
          const SizedBox(height: 14),
          _infoCard(),
          if (showDrugs) ...[
            const SizedBox(height: 22),
            _sectionLabel('Drugs (${_items.length})'),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.divider),
                ),
                child: Center(
                  child: Text(
                    'No drug items found',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _C.textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ..._items.map((item) => _drugItemCard(item)),
          ],
          if (showChecks) ...[
            const SizedBox(height: 22),
            _sectionLabel('Compliance Checks (${_checks.length})'),
            if (_checks.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.divider),
                ),
                child: Center(
                  child: Text(
                    'No checks found',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _C.textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              ..._checks.map((check) => _checkCard(check)),
          ],
          if (showRemarks) ...[
            const SizedBox(height: 22),
            _sectionLabel('Remarks'),
            _remarksCard(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _inspection?['status']?.toString() ?? '';
    final meta = _statusMeta(status);

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Inspection Detail',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isLoading && _inspection != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  meta['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(color: _C.bg),
          ),
        ),
      ),
      body: _isLoading
          ? _skeletonLoader()
          : _inspection == null
          ? _emptyState()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 12),
                  child: _filterBar(),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }
}
