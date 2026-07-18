import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../controller/patient_list_controller.dart';
import 'patient_detail_screen.dart';

enum PatientFilter { all, today, thisWeek, thisMonth }

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
  static const textPrimary = Color(0xFF0F0A1E);
  static const textSub = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE9E4F8);
  static const shadow = Color(0x186C2EF2);
  static const inputBg = Color(0xFFF3F0FD);
}

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

class PatientList extends StatelessWidget {
  const PatientList({super.key});

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

  bool _matchesFilter(String? dateStr, PatientFilter filter) {
    if (filter == PatientFilter.all) return true;
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (filter == PatientFilter.today) {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }
      if (filter == PatientFilter.thisWeek) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final end = start.add(const Duration(days: 7));
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end);
      }
      if (filter == PatientFilter.thisMonth) {
        return date.year == now.year && date.month == now.month;
      }
    } catch (_) {}
    return false;
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.18;
    if (w > 600) return w * 0.08;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientListController());
    final activeFilter = PatientFilter.all.obs;
    final hp = _hPad(context);

    return Scaffold(
      backgroundColor: _T.bg,
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
          'Patients',
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
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildSkeleton(hp);
        }

        return Obx(() {
          final activeF = activeFilter.value;
          final filtered = controller.filteredPatients
              .where((p) => _matchesFilter(p['last_purchase_at'], activeF))
              .toList();

          return Column(
            children: [
              Container(
                color: _T.bg,
                padding: EdgeInsets.fromLTRB(hp, 4, hp, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _T.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _T.divider, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: _T.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchPatients,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.inter(
                          color: _T.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or mobile...',
                          hintStyle: GoogleFonts.inter(
                            color: _T.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _T.primary.withOpacity(0.6),
                            size: 20,
                          ),
                          suffixIcon:
                              controller.searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: _T.textSub,
                                    size: 18,
                                  ),
                                  onPressed: controller.clearSearch,
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
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(
                            'All  (${controller.filteredPatients.length})',
                            PatientFilter.all,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'Today',
                            PatientFilter.today,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'This Week',
                            PatientFilter.thisWeek,
                            activeFilter,
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            'This Month',
                            PatientFilter.thisMonth,
                            activeFilter,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: _T.divider),
                    const SizedBox(height: 10),
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
                          '${filtered.length} patient${filtered.length != 1 ? "s" : ""}',
                          style: GoogleFonts.inter(
                            color: _T.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: _T.primary,
                        backgroundColor: _T.surface,
                        onRefresh: controller.loadPatients,
                        child: ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(hp, 12, hp, 30),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final patient = filtered[index];
                            final name =
                                patient['patient_name']?.toString() ?? '';
                            final mobile =
                                patient['patient_mobile']?.toString() ?? '';
                            final lastPurchase = _formatDate(
                              patient['last_purchase_at'],
                            );
                            final initial = name.isNotEmpty
                                ? name.substring(0, 1).toUpperCase()
                                : 'P';
                            final totalPurchases = patient['total_purchases']
                                ?.toString();

                            return GestureDetector(
                              onTap: () => Get.to(
                                () =>
                                    PatientDetailScreen(patientMobile: mobile),
                              ),
                              child: Container(
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
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF50A586),
                                                  Color(0xFF09D6A2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _T.primary.withOpacity(
                                                    0.3,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                initial,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    color: _T.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone_rounded,
                                                      size: 11,
                                                      color: _T.textMuted,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      mobile.isNotEmpty
                                                          ? mobile
                                                          : 'No number',
                                                      style: GoogleFonts.inter(
                                                        color: _T.textSub,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: _T.primary,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        10,
                                        16,
                                        12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    color: _T.primarySoft,
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                                Expanded(
                                                  child: Text(
                                                    lastPurchase,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      color: _T.textSub,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (totalPurchases != null) ...[
                                            const SizedBox(width: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _T.successSoft,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _T.success.withOpacity(
                                                    0.2,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.shopping_bag_rounded,
                                                    size: 11,
                                                    color: _T.success,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$totalPurchases orders',
                                                    style: GoogleFonts.inter(
                                                      color: _T.success,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        });
      }),
    );
  }

  Widget _filterChip(
    String label,
    PatientFilter filter,
    Rx<PatientFilter> active,
  ) {
    return Obx(() {
      final selected = active.value == filter;
      return GestureDetector(
        onTap: () => active.value = filter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _T.primary : _T.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? _T.primary : _T.divider,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _T.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: _T.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? Colors.white : _T.textSub,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

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
              Icons.person_search_rounded,
              size: 40,
              color: _T.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: GoogleFonts.inter(
              color: _T.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter',
            style: GoogleFonts.inter(color: _T.textSub, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(double hp) {
    return Column(
      children: [
        Container(
          color: _T.bg,
          padding: EdgeInsets.fromLTRB(hp, 4, hp, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Skeleton(height: 50, radius: 14),
              const SizedBox(height: 12),
              Row(
                children: const [
                  _Skeleton(width: 80, height: 36, radius: 30),
                  SizedBox(width: 8),
                  _Skeleton(width: 70, height: 36, radius: 30),
                  SizedBox(width: 8),
                  _Skeleton(width: 90, height: 36, radius: 30),
                  SizedBox(width: 8),
                  _Skeleton(width: 100, height: 36, radius: 30),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: _T.divider),
              const SizedBox(height: 10),
              const _Skeleton(width: 100, height: 14, radius: 4),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hp, 12, hp, 30),
            itemCount: 6,
            itemBuilder: (_, __) => Container(
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
                        _Skeleton(width: 48, height: 48, radius: 14),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Skeleton(width: 140, height: 14, radius: 4),
                              SizedBox(height: 8),
                              _Skeleton(width: 100, height: 11, radius: 4),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        _Skeleton(width: 36, height: 36, radius: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Row(
                      children: const [
                        _Skeleton(width: 28, height: 28, radius: 8),
                        SizedBox(width: 8),
                        _Skeleton(width: 160, height: 12, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
