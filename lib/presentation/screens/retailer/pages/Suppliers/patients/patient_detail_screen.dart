import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../controller/patient_detail_controller.dart';

// ── Design tokens (matches PatientList exactly) ─────────────────────────────
class _T {
  static const bg = Color(0xFFF7F5FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0EDFB);
  static const primary = Color(0xFF04936A);
  static const primaryDark = Color(0xFF03A563);
  static const primarySoft = Color(0xFFEDE8FB);
  static const primaryMid = Color(0xFFD4C7F9);
  static const success = Color(0xFF059669);
  static const successSoft = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFF8EC);
  static const textPrimary = Color(0xFF0F0A1E);
  static const textSub = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE9E4F8);
  static const shadow = Color(0x186C2EF2);
  static const inputBg = Color(0xFFF3F0FD);

  // accent used only for drug/purchase cards
  static const accent = Color(0xFF6C2EF2);
  static const accentSoft = Color(0xFFEDE8FB);
}

// ── Skeleton widget (identical to PatientList) ───────────────────────────────
class _Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Skeleton({
    this.width = double.infinity,
    this.height = 16,
    this.radius = 10,
  });

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                const Color(0xFFE5E0F5),
                const Color(0xFFD0C8EE),
                _ctrl.value,
              )!,
              Color.lerp(
                const Color(0xFFD0C8EE),
                const Color(0xFFE5E0F5),
                _ctrl.value,
              )!,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class PatientDetailScreen extends StatelessWidget {
  final String patientMobile;

  const PatientDetailScreen({super.key, required this.patientMobile});

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;
      if (diff == 0) return 'Today, ${DateFormat('hh:mm a').format(date)}';
      if (diff == 1) return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return value;
    }
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16.0;
  }

  // ── Info stat card (Total Purchases / Total Qty / Last Purchase) ──────────
  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: _T.shadow,
            blurRadius: 10,
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
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: _T.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _T.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail row inside a sale card ─────────────────────────────────────────
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            color: _T.textSub,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _T.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientDetailController(patientMobile));
    final hp = _hPad(context);

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patient Details',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildSkeleton(hp);
        }

        if (controller.patient.isEmpty) {
          return _buildEmpty();
        }

        final patient = controller.patient;
        final name = controller.value(patient['patient_name']);
        final mobile = controller.value(patient['patient_mobile']);
        final totalPurchases = controller.value(patient['total_purchases']);
        final totalQty = controller.value(patient['total_quantity']);
        final lastPurchase = _formatDate(
          patient['last_purchase_at']?.toString(),
        );
        final initial = name.isNotEmpty
            ? name.substring(0, 1).toUpperCase()
            : 'P';

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(hp, 14, hp, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: _T.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _T.divider),
                  boxShadow: [
                    BoxShadow(
                      color: _T.shadow,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF50A586), Color(0xFF09D6A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: _T.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: _T.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: _T.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mobile.isNotEmpty ? mobile : 'No number',
                          style: GoogleFonts.inter(
                            color: _T.textSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      Icons.receipt_long_rounded,
                      'Total Purchases',
                      totalPurchases,
                      _T.accent,
                      _T.accentSoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      Icons.inventory_2_rounded,
                      'Total Quantity',
                      totalQty,
                      _T.success,
                      _T.successSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.access_time_rounded,
                'Last Purchase',
                lastPurchase,
                _T.warning,
                _T.warningSoft,
              ),

              const SizedBox(height: 20),
              Container(height: 1, color: _T.divider),
              const SizedBox(height: 14),

              // ── Section header ────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _T.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PURCHASE HISTORY',
                    style: GoogleFonts.inter(
                      color: _T.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _T.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.sales.length} record${controller.sales.length != 1 ? "s" : ""}',
                      style: GoogleFonts.inter(
                        color: _T.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Sales list / empty ─────────────────────────────────────────
              controller.sales.isEmpty
                  ? _buildEmptyHistory()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.sales.length,
                      itemBuilder: (context, index) {
                        final sale = controller.sales[index];
                        final drugName = sale['drug_name']?.toString() ?? '';
                        final batchNo = sale['batch_no']?.toString() ?? 'N/A';
                        final qty = sale['quantity']?.toString() ?? '0';
                        final price = sale['price']?.toString() ?? '0';
                        final doctor = sale['doctor_name']?.toString() ?? 'N/A';
                        final abhaId = sale['abha_id']?.toString() ?? '';
                        final payment =
                            sale['payment_mode']?.toString() ?? 'N/A';
                        final createdAt = _formatDate(
                          sale['created_at']?.toString(),
                        );

                        final isCash = payment.toLowerCase() == 'cash';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: _T.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _T.divider),
                            boxShadow: [
                              BoxShadow(
                                color: _T.shadow,
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // card header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: const BoxDecoration(
                                  color: _T.primarySoft,
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
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF50A586),
                                            Color(0xFF09D6A2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _T.primary.withOpacity(0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.medication_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        drugName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: _T.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
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
                                        color: isCash
                                            ? _T.successSoft
                                            : _T.primarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isCash
                                              ? _T.success.withOpacity(0.2)
                                              : _T.accent.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        payment.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          color: isCash
                                              ? _T.success
                                              : _T.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // card body
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  14,
                                ),
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      Icons.qr_code_rounded,
                                      'Batch',
                                      batchNo,
                                      _T.accent,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      Icons.inventory_2_rounded,
                                      'Quantity',
                                      qty,
                                      _T.success,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      Icons.currency_rupee_rounded,
                                      'Price',
                                      '₹$price',
                                      _T.warning,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      Icons.local_hospital_rounded,
                                      'Doctor',
                                      doctor,
                                      _T.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      Icons.badge_rounded,
                                      'ABHA ID',
                                      abhaId.isEmpty ? 'N/A' : abhaId,
                                      _T.warning,
                                    ),
                                    const SizedBox(height: 10),
                                    Container(height: 1, color: _T.divider),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _T.primarySoft,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: _T.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          createdAt,
                                          style: GoogleFonts.inter(
                                            color: _T.textSub,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
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
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  // ── Empty states ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _T.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.person_off_rounded,
              size: 40,
              color: _T.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: GoogleFonts.inter(
              color: _T.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Patient record could not be loaded',
            style: GoogleFonts.inter(color: _T.textSub, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _T.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 34,
                color: _T.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No purchase history',
              style: GoogleFonts.inter(
                color: _T.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No records found for this patient',
              style: GoogleFonts.inter(color: _T.textSub, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton loader ────────────────────────────────────────────────────────
  Widget _buildSkeleton(double hp) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hp, 14, hp, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profile card skeleton
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _T.divider),
            ),
            child: Column(
              children: [
                const _Skeleton(width: 72, height: 72, radius: 22),
                const SizedBox(height: 12),
                const _Skeleton(width: 160, height: 18, radius: 6),
                const SizedBox(height: 8),
                const _Skeleton(width: 110, height: 13, radius: 4),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // stat cards skeleton
          Row(
            children: const [
              Expanded(child: _Skeleton(height: 68, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: _Skeleton(height: 68, radius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const _Skeleton(height: 68, radius: 16),
          const SizedBox(height: 20),
          Container(height: 1, color: _T.divider),
          const SizedBox(height: 14),
          const _Skeleton(width: 160, height: 16, radius: 6),
          const SizedBox(height: 14),
          // sale card skeletons
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _T.divider),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: _T.primarySoft,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: const [
                        _Skeleton(width: 46, height: 46, radius: 14),
                        SizedBox(width: 12),
                        Expanded(child: _Skeleton(height: 15, radius: 4)),
                        SizedBox(width: 12),
                        _Skeleton(width: 60, height: 28, radius: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      children: const [
                        _Skeleton(height: 28, radius: 8),
                        SizedBox(height: 8),
                        _Skeleton(height: 28, radius: 8),
                        SizedBox(height: 8),
                        _Skeleton(height: 28, radius: 8),
                        SizedBox(height: 8),
                        _Skeleton(width: 140, height: 28, radius: 8),
                      ],
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
}
