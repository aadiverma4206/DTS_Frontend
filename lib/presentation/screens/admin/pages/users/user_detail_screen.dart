import 'package:drug_tracking_system/core/services/api_service/user_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFEF3C7);
  static const violet = Color(0xFF7C3AED);
  static const violetSoft = Color(0xFFEDE9FE);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isActionLoading = false;

  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    loadUser();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 1000) return w * 0.28;
    if (w > 700) return w * 0.12;
    return 16;
  }

  Future<void> loadUser() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await UserApi.getUserDetail(widget.userId);
      if (!mounted) return;
      setState(() {
        user = data.isNotEmpty ? data : null;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        user = null;
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load user details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  Future<void> toggleBlock(int userId, String status) async {
    setState(() => isActionLoading = true);
    try {
      if (status == 'blocked') {
        await UserApi.approveUser(userId);
        Get.snackbar(
          'Success',
          'User unblocked successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _C.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(14),
          borderRadius: 14,
        );
      } else {
        await UserApi.rejectUser(userId);
        Get.snackbar(
          'Success',
          'User blocked successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _C.rose,
          colorText: Colors.white,
          margin: const EdgeInsets.all(14),
          borderRadius: 14,
        );
      }
      await loadUser();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to update user status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    } finally {
      if (mounted) setState(() => isActionLoading = false);
    }
  }


  Widget _shimmerBox({
    double width = double.infinity,
    double height = 16,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: [
                (_shimmerCtrl.value - 0.35).clamp(0.0, 1.0),
                _shimmerCtrl.value.clamp(0.0, 1.0),
                (_shimmerCtrl.value + 0.35).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerProfileCard() {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _shimmerBox(width: 60, height: 60, radius: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 160, height: 16, radius: 6),
                const SizedBox(height: 8),
                _shimmerBox(width: 200, height: 12, radius: 5),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _shimmerBox(width: 72, height: 26, radius: 10),
                    const SizedBox(width: 8),
                    _shimmerBox(width: 64, height: 26, radius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerContactCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerSectionLabel(),
        _card(
          child: Column(
            children: [
              _shimmerInfoRow(),
              const SizedBox(height: 12),
              _shimmerInfoRow(),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _shimmerRoleDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerSectionLabel(),
        _card(
          child: Column(
            children: [
              _shimmerInfoRow(),
              const SizedBox(height: 12),
              _shimmerInfoRow(),
              const SizedBox(height: 12),
              _shimmerInfoRow(),
              const SizedBox(height: 12),
              _shimmerInfoRow(),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _shimmerActionButton() {
    return _shimmerBox(width: double.infinity, height: 54, radius: 16);
  }

  Widget _shimmerSectionLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _shimmerBox(width: 4, height: 18, radius: 4),
          const SizedBox(width: 8),
          _shimmerBox(width: 100, height: 14, radius: 6),
        ],
      ),
    );
  }

  Widget _shimmerInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _shimmerBox(width: 36, height: 36, radius: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: 70, height: 10, radius: 5),
              const SizedBox(height: 6),
              _shimmerBox(width: 140, height: 13, radius: 5),
            ],
          ),
        ),
      ],
    );
  }


  String _roleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Admin';
      case 3:
        return 'Wholesaler';
      case 4:
        return 'Retailer';
      case 5:
        return 'Inspector';
      default:
        return 'Unknown';
    }
  }

  _RoleStyle _roleStyle(int roleId) {
    switch (roleId) {
      case 1:
        return _RoleStyle(
          _C.violet,
          _C.violetSoft,
          Icons.admin_panel_settings_rounded,
        );
      case 3:
        return _RoleStyle(_C.blue, _C.blueSoft, Icons.warehouse_rounded);
      case 4:
        return _RoleStyle(_C.green, _C.greenSoft, Icons.store_rounded);
      case 5:
        return _RoleStyle(_C.amber, _C.amberSoft, Icons.verified_user_rounded);
      default:
        return _RoleStyle(_C.textSub, _C.bg, Icons.person_rounded);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return _C.green;
      case 'blocked':
        return _C.rose;
      default:
        return _C.textSub;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'active':
        return _C.greenSoft;
      case 'blocked':
        return _C.roseSoft;
      default:
        return _C.bg;
    }
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _miniChip(String label, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: _C.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: _C.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(int roleId, String status) {
    final name = user!['name']?.toString() ?? '';
    final email = user!['email']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final rs = _roleStyle(roleId);

    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _C.indigo,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Unknown',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email.isNotEmpty ? email : 'No Email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: _C.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _miniChip(_roleName(roleId), rs.color, rs.bg, rs.icon),
                    if (status.isNotEmpty)
                      _miniChip(
                        status.toUpperCase(),
                        _statusColor(status),
                        _statusBg(status),
                        status == 'active'
                            ? Icons.check_circle_rounded
                            : Icons.block_rounded,
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

  Widget _contactCard() {
    final mobile = user!['mobile']?.toString() ?? '';
    final email = user!['email']?.toString() ?? '';

    final hasAny = mobile.isNotEmpty || email.isNotEmpty;
    if (!hasAny) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Contact'),
        _card(
          child: Column(
            children: [
              _infoRow('Mobile', mobile, Icons.phone_rounded),
              _infoRow('Email', email, Icons.email_rounded),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _roleDetailsCard(int roleId) {
    final roleData = (user!['roleData'] ?? {}) as Map;
    if (roleData.isEmpty) return const SizedBox.shrink();

    List<Widget> rows = [];

    if (roleId == 3) {
      rows = [
        _infoRow(
          'Company Name',
          roleData['company_name']?.toString() ?? '',
          Icons.business_rounded,
        ),
        _infoRow(
          'GSTIN',
          roleData['gstin']?.toString() ?? '',
          Icons.receipt_long_rounded,
        ),
        _infoRow(
          'Drug License No.',
          roleData['drug_license_no']?.toString() ?? '',
          Icons.verified_rounded,
        ),
        _infoRow(
          'Address',
          roleData['address']?.toString() ?? '',
          Icons.location_on_rounded,
        ),
      ];
    } else if (roleId == 4) {
      rows = [
        _infoRow(
          'Shop Name',
          roleData['shop_name']?.toString() ?? '',
          Icons.storefront_rounded,
        ),
        _infoRow(
          'GSTIN',
          roleData['gstin']?.toString() ?? '',
          Icons.receipt_long_rounded,
        ),
        _infoRow(
          'Drug License No.',
          roleData['drug_license_no']?.toString() ?? '',
          Icons.verified_rounded,
        ),
        _infoRow(
          'Address',
          roleData['address']?.toString() ?? '',
          Icons.location_on_rounded,
        ),
      ];
    } else if (roleId == 5) {
      rows = [
        _infoRow(
          'Department',
          roleData['department']?.toString() ?? '',
          Icons.apartment_rounded,
        ),
      ];
    }

    final filtered = rows.where((w) => w is! SizedBox).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('${_roleName(roleId)} Details'),
        _card(child: Column(children: filtered)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _actionButton(int userId, String status) {
    final isBlocked = status == 'blocked';
    final btnColor = isBlocked ? _C.green : _C.rose;
    final btnBg = isBlocked ? _C.greenSoft : _C.roseSoft;
    final label = isBlocked ? 'Unblock User' : 'Block User';
    final icon = isBlocked ? Icons.lock_open_rounded : Icons.block_rounded;

    return GestureDetector(
      onTap: isActionLoading ? null : () => toggleBlock(userId, status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActionLoading ? _C.divider : btnBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActionLoading
                ? _C.divider
                : btnColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isActionLoading
                  ? Colors.transparent
                  : btnColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isActionLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: _C.textSub,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: btnColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: btnColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }


  Widget _shimmerPage(double hPad) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerSectionLabel(),
            _shimmerProfileCard(),
            const SizedBox(height: 16),

            _shimmerContactCard(),

            _shimmerRoleDetailsCard(),

            _shimmerActionButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = _hPad(context);
    final roleId = int.tryParse(user?['role_id']?.toString() ?? '0') ?? 0;
    final userId = int.tryParse(user?['user_id']?.toString() ?? '0') ?? 0;
    final status = user?['status']?.toString() ?? '';

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'User Details',
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
      body: isLoading
          ? _shimmerPage(hPad)
          : user == null
          ? Center(
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
                      Icons.person_off_rounded,
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
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Profile'),
                    _profileCard(roleId, status),
                    const SizedBox(height: 16),
                    _contactCard(),
                    _roleDetailsCard(roleId),
                    if (status.isNotEmpty && userId > 0)
                      _actionButton(userId, status),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RoleStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  const _RoleStyle(this.color, this.bg, this.icon);
}
