import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/api_service/inspection_api.dart';

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
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class _BlinkingWidget extends StatefulWidget {
  final Widget child;
  const _BlinkingWidget({required this.child});

  @override
  State<_BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<_BlinkingWidget>
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
      begin: 1.0,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _anim, child: widget.child);
  }
}

class CreateInspectionScreen extends StatefulWidget {
  final int targetUserId;
  final String targetName;
  final String inspectionType;

  const CreateInspectionScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.inspectionType,
  });

  @override
  State<CreateInspectionScreen> createState() => _CreateInspectionScreenState();
}

class _CreateInspectionScreenState extends State<CreateInspectionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _filterIndex = 0;

  List<Map<String, dynamic>> _drugs = [];
  Map<int, int> _physicalTotals = {};
  Map<int, TextEditingController> _controllers = {};

  List<Map<String, dynamic>> _checks = [
    {'check_name': 'License Valid', 'check_value': 'yes'},
    {'check_name': 'Document Verified', 'check_value': 'yes'},
    {'check_name': 'Storage Condition OK', 'check_value': 'yes'},
    {'check_name': 'Stock Verified', 'check_value': 'yes'},
  ];

  final TextEditingController _remarksCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<String> _filters = ['All', 'Drugs', 'Checks', 'Remarks'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadStock();
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    try {
      final data = await InspectionApi.getInspectionStock(widget.targetUserId);
      if (!mounted) return;
      for (var d in data) {
        _controllers[d['drug_id']] = TextEditingController();
      }
      setState(() {
        _drugs = data;
        _isLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _drugs = [];
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  int _systemTotal(List batches) => batches.fold<int>(0, (sum, b) {
    final qty = b['system_qty'];
    if (qty is int) return sum + qty;
    if (qty is num) return sum + qty.toInt();
    return sum;
  });

  int _calcTotalSystem() =>
      _drugs.fold(0, (s, d) => s + _systemTotal(d['batches'] ?? []));

  int _calcTotalPhysical() =>
      _drugs.fold(0, (s, d) => s + (_physicalTotals[d['drug_id']] ?? 0));

  List<Map<String, dynamic>> _buildItems() {
    final items = <Map<String, dynamic>>[];
    for (var drug in _drugs) {
      final drugId = drug['drug_id'];
      final batches = drug['batches'] ?? [];
      final totalSystem = _systemTotal(batches);
      final physicalTotal = _physicalTotals[drugId] ?? 0;
      int remaining = physicalTotal;
      for (int i = 0; i < batches.length; i++) {
        final b = batches[i];
        final system = b['system_qty'] ?? 0;
        int physical;
        if (i == batches.length - 1) {
          physical = remaining;
        } else {
          final ratio = totalSystem == 0 ? 0.0 : system / totalSystem;
          physical = (physicalTotal * ratio).round();
          remaining -= physical;
        }
        items.add({
          'batch_id': b['batch_id'],
          'drug_id': drugId,
          'physical_qty': physical,
        });
      }
    }
    return items;
  }

  Future<void> _submit() async {
    if (_drugs.isEmpty) return;
    for (var d in _drugs) {
      if (!_physicalTotals.containsKey(d['drug_id'])) {
        Get.snackbar(
          'Warning',
          'Please fill all physical stock values',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _C.amber,
          colorText: Colors.white,
          margin: const EdgeInsets.all(14),
          borderRadius: 14,
        );
        setState(() => _filterIndex = 1);
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      await InspectionApi.createInspection(
        targetUserId: widget.targetUserId,
        inspectionType: widget.inspectionType,
        items: _buildItems(),
        checks: _checks,
        totalSystemQty: _calcTotalSystem(),
        totalPhysicalQty: _calcTotalPhysical(),
        remarks: _remarksCtrl.text,
      );
      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Success',
        'Inspection submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      padding: const EdgeInsets.only(bottom: 14),
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

  Widget _skeletonBox({
    double width = double.infinity,
    double height = 14,
    double radius = 8,
  }) {
    return _BlinkingWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _C.divider,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _skeletonSummaryRow() {
    return _BlinkingWidget(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _C.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: _C.divider,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonDrugCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                _BlinkingWidget(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _C.divider,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(width: 160, height: 14),
                      const SizedBox(height: 7),
                      _skeletonBox(width: 100, height: 11),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _BlinkingWidget(
                  child: Container(
                    width: 80,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _C.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(
                  2,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _BlinkingWidget(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _C.divider,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _skeletonBox(height: 11)),
                        const SizedBox(width: 8),
                        _BlinkingWidget(
                          child: Container(
                            width: 36,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _C.divider,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: _BlinkingWidget(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _C.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonCheckCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          _BlinkingWidget(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.divider,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _skeletonBox(height: 14)),
          const SizedBox(width: 12),
          _BlinkingWidget(
            child: Container(
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: _C.divider,
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonRemarks() {
    return _BlinkingWidget(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: _C.divider,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _skeletonFilterBar() {
    return _BlinkingWidget(
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _C.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.divider),
        ),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 120),
      children: [
        const SizedBox(height: 14),
        _skeletonSummaryRow(),
        const SizedBox(height: 20),
        _sectionLabel('Drugs'),
        ...List.generate(3, (_) => _skeletonDrugCard()),
        const SizedBox(height: 20),
        _sectionLabel('Compliance Checks'),
        ...List.generate(4, (_) => _skeletonCheckCard()),
        const SizedBox(height: 20),
        _sectionLabel('Remarks'),
        _skeletonRemarks(),
      ],
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

  Widget _summaryRow() {
    final totalSys = _calcTotalSystem();
    final totalPhy = _calcTotalPhysical();
    final matched = totalSys == totalPhy && _drugs.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: matched ? _C.greenSoft : _C.amberSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: matched ? _C.green : _C.amber),
      ),
      child: Row(
        children: [
          Icon(
            matched ? Icons.check_circle_rounded : Icons.info_rounded,
            color: matched ? _C.green : _C.amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'System: $totalSys  •  Physical: $totalPhy  •  ${matched ? "Matched ✓" : "Mismatch"}',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: matched ? _C.green : _C.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drugCard(Map<String, dynamic> drug) {
    final batches = drug['batches'] ?? [];
    final drugId = drug['drug_id'];
    final drugName = drug['drug_name'] ?? '';
    final totalSystem = _systemTotal(batches);
    final entered = _physicalTotals[drugId];
    final mismatch = entered != null && entered != totalSystem;
    final matched = entered != null && entered == totalSystem;

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String statusText;

    if (entered == null) {
      statusColor = _C.amber;
      statusBg = _C.amberSoft;
      statusIcon = Icons.edit_note_rounded;
      statusText = 'Pending entry';
    } else if (mismatch) {
      statusColor = _C.rose;
      statusBg = _C.roseSoft;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Mismatch detected';
    } else {
      statusColor = _C.green;
      statusBg = _C.greenSoft;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Matched';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: _C.indigoSoft,
                    borderRadius: BorderRadius.circular(12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                      Text(
                        'System Total: $totalSystem',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: _C.textSub,
                          fontWeight: FontWeight.w600,
                        ),
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
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (batches.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: (batches as List).map<Widget>((b) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _C.indigo,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${b["batch_no"]}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _C.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _C.blueSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${b["system_qty"]}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _C.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: TextField(
              controller: _controllers[drugId],
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (val) {
                final qty = int.tryParse(val);
                setState(() {
                  if (qty != null) {
                    _physicalTotals[drugId] = qty;
                  } else {
                    _physicalTotals.remove(drugId);
                  }
                });
              },
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Physical Total',
                labelStyle: GoogleFonts.nunito(
                  fontSize: 13,
                  color: _C.textSub,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter counted stock',
                hintStyle: GoogleFonts.nunito(fontSize: 12, color: _C.textSub),
                prefixIcon: const Icon(
                  Icons.inventory_2_rounded,
                  color: _C.indigo,
                  size: 18,
                ),
                filled: true,
                fillColor: _C.bg,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _C.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _C.indigo, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkCard(int index) {
    final check = _checks[index];
    final isYes = check['check_value'] == 'yes';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              check['check_name'],
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: isYes,
            activeColor: _C.green,
            inactiveThumbColor: _C.rose,
            inactiveTrackColor: _C.roseSoft,
            onChanged: (val) {
              setState(() {
                check['check_value'] = val ? 'yes' : 'no';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _remarksField() {
    return Container(
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
      child: TextField(
        controller: _remarksCtrl,
        maxLines: 5,
        textInputAction: TextInputAction.done,
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: _C.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: 'Remarks',
          labelStyle: GoogleFonts.nunito(
            fontSize: 13,
            color: _C.textSub,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Add any inspection notes here...',
          hintStyle: GoogleFonts.nunito(fontSize: 13, color: _C.textSub),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.notes_rounded, color: _C.indigo, size: 20),
          ),
          filled: true,
          fillColor: _C.bg,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _C.indigo, width: 1.5),
          ),
        ),
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
        padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 120),
        children: [
          const SizedBox(height: 14),
          _summaryRow(),
          if (showDrugs) ...[
            const SizedBox(height: 20),
            _sectionLabel('Drugs (${_drugs.length})'),
            ...List.generate(_drugs.length, (i) => _drugCard(_drugs[i])),
          ],
          if (showChecks) ...[
            const SizedBox(height: 20),
            _sectionLabel('Compliance Checks'),
            ...List.generate(_checks.length, (i) => _checkCard(i)),
          ],
          if (showRemarks) ...[
            const SizedBox(height: 20),
            _sectionLabel('Remarks'),
            _remarksField(),
          ],
          const SizedBox(height: 20),
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
              Icons.inventory_2_rounded,
              size: 38,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Stock Available',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This target has no recorded stock',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.targetName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              widget.inspectionType[0].toUpperCase() +
                  widget.inspectionType.substring(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(color: _C.bg),
          ),
        ),
      ),
      body: _isLoading
          ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 12),
                  child: _skeletonFilterBar(),
                ),
                Expanded(child: _buildSkeletonContent()),
              ],
            )
          : _drugs.isEmpty
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
      bottomNavigationBar: _drugs.isEmpty && !_isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(_hPad, 10, _hPad, 14),
                child: GestureDetector(
                  onTap: (_isSubmitting || _isLoading) ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      color: (_isSubmitting || _isLoading)
                          ? _C.indigo.withOpacity(0.6)
                          : _C.indigo,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _C.indigo.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Submit Inspection',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
