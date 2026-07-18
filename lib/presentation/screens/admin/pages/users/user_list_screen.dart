import 'package:drug_tracking_system/core/services/api_service/admin_api.dart';
import 'package:drug_tracking_system/presentation/screens/admin/pages/users/user_detail_screen.dart';
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

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  bool isOverviewLoading = true;
  bool isListLoading = true;
  bool isOverviewReloading = false;

  int selectedRole = 0;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int _adminCount = 0;
  int _inspectorCount = 0;
  int _wholesalerCount = 0;
  int _retailerCount = 0;

  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadStaticUI();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _loadStaticUI() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      setState(() {
        isOverviewLoading = true;
        isListLoading = true;
      });
    });
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      isOverviewLoading = true;
      isListLoading = true;
    });
    try {
      final data = await AdminApi.getAllUsers();
      if (!mounted) return;
      users = data;
      _computeOverview();
      applyFilter();
      setState(() {
        isOverviewLoading = false;
        isListLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isOverviewLoading = false;
        isListLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load users',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
  }

  Future<void> _reloadOverview() async {
    if (!mounted || isOverviewReloading) return;
    setState(() => isOverviewReloading = true);
    try {
      final data = await AdminApi.getAllUsers();
      if (!mounted) return;
      users = data;
      _computeOverview();
      applyFilter();
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to reload overview',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.rose,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }
    if (!mounted) return;
    setState(() => isOverviewReloading = false);
  }

  void _computeOverview() {
    _adminCount = users.where((u) => _roleId(u) == 1).length;
    _inspectorCount = users.where((u) => _roleId(u) == 5).length;
    _wholesalerCount = users.where((u) => _roleId(u) == 3).length;
    _retailerCount = users.where((u) => _roleId(u) == 4).length;
  }

  int _roleId(Map<String, dynamic> u) =>
      int.tryParse(u['role_id']?.toString() ?? '0') ?? 0;

  void applyFilter() {
    List<Map<String, dynamic>> temp = users;
    if (selectedRole != 0) {
      temp = temp.where((u) => _roleId(u) == selectedRole).toList();
    }
    if (searchQuery.isNotEmpty) {
      temp = temp.where((u) {
        final name = u['name']?.toString().toLowerCase() ?? '';
        final email = u['email']?.toString().toLowerCase() ?? '';
        return name.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
    }
    filteredUsers = temp;
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return w * 0.25;
    if (w > 1000) return w * 0.28;
    if (w > 700) return w * 0.12;
    return 16;
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
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
              stops: [
                (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                _shimmerCtrl.value.clamp(0.0, 1.0),
                (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _overviewShimmerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _shimmerBox(width: 30, height: 30, radius: 8),
          const SizedBox(height: 8),
          _shimmerBox(width: 34, height: 16, radius: 6),
          const SizedBox(height: 5),
          _shimmerBox(width: 52, height: 10, radius: 5),
        ],
      ),
    );
  }

  Widget _listShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          _shimmerBox(width: 46, height: 46, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 130, height: 14, radius: 6),
                const SizedBox(height: 7),
                _shimmerBox(width: 170, height: 11, radius: 5),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _shimmerBox(width: 60, height: 22, radius: 8),
                    const SizedBox(width: 6),
                    _shimmerBox(width: 55, height: 22, radius: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _shimmerBox(width: 32, height: 32, radius: 10),
        ],
      ),
    );
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

  Widget _overviewCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _C.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _C.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection(double hPad) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  'Overview',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: isOverviewReloading ? null : _reloadOverview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _C.indigoSoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _C.indigo.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isOverviewReloading
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  color: _C.indigo,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: _C.indigo,
                              ),
                        const SizedBox(width: 5),
                        Text(
                          'Reload',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
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
            const SizedBox(height: 12),
            isOverviewLoading
                ? Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                          child: _overviewShimmerCard(),
                        ),
                      );
                    }),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _overviewCard(
                          'Admin',
                          '$_adminCount',
                          Icons.admin_panel_settings_rounded,
                          _C.violet,
                          _C.violetSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Inspector',
                          '$_inspectorCount',
                          Icons.verified_user_rounded,
                          _C.amber,
                          _C.amberSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Wholesaler',
                          '$_wholesalerCount',
                          Icons.warehouse_rounded,
                          _C.blue,
                          _C.blueSoft,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _overviewCard(
                          'Retailer',
                          '$_retailerCount',
                          Icons.store_rounded,
                          _C.green,
                          _C.greenSoft,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
          ],
        ),
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
        onChanged: (val) {
          searchQuery = val.toLowerCase();
          applyFilter();
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search name or email...',
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
          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    searchQuery = '';
                    applyFilter();
                    setState(() {});
                  },
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

  Widget _roleFilterChips() {
    const roles = [
      _RoleFilter(0, 'All', Icons.people_alt_rounded, _C.indigo, _C.indigoSoft),
      _RoleFilter(
        1,
        'Admin',
        Icons.admin_panel_settings_rounded,
        _C.violet,
        _C.violetSoft,
      ),
      _RoleFilter(
        3,
        'Wholesaler',
        Icons.warehouse_rounded,
        _C.blue,
        _C.blueSoft,
      ),
      _RoleFilter(4, 'Retailer', Icons.store_rounded, _C.green, _C.greenSoft),
      _RoleFilter(
        5,
        'Inspector',
        Icons.verified_user_rounded,
        _C.amber,
        _C.amberSoft,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final r = roles[i];
          final selected = selectedRole == r.id;
          return GestureDetector(
            onTap: () {
              selectedRole = r.id;
              applyFilter();
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? r.color : _C.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? r.color : _C.divider,
                  width: selected ? 0 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? r.color.withValues(alpha: 0.2)
                        : _C.shadow,
                    blurRadius: selected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    r.icon,
                    size: 16,
                    color: selected ? Colors.white : r.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.label,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: selected ? Colors.white : _C.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final roleId = _roleId(user);
    final status = user['status']?.toString() ?? '';
    final userId = int.tryParse(user['user_id']?.toString() ?? '0') ?? 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final rs = _roleStyle(roleId);

    return GestureDetector(
      onTap: () {
        if (userId <= 0) {
          Get.snackbar(
            'Error',
            'Invalid User ID',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _C.rose,
            colorText: Colors.white,
            margin: const EdgeInsets.all(14),
            borderRadius: 14,
          );
          return;
        }
        Get.to(() => UserDetailScreen(userId: userId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email.isNotEmpty ? email : 'No Email',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: _C.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
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
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: _C.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = _hPad(context);
    final filtered = filteredUsers;

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'User Management',
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
          child: RefreshIndicator(
            color: _C.indigo,
            onRefresh: _loadUsers,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _overviewSection(hPad),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Search'),
                        _searchField(),
                        const SizedBox(height: 16),
                        _sectionLabel('Filter by Role'),
                        _roleFilterChips(),
                        const SizedBox(height: 16),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isListLoading)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.indigoSoft,
                                  borderRadius: BorderRadius.circular(8),
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
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 30),
                  sliver: isListLoading
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => _listShimmerCard(),
                            childCount: 6,
                          ),
                        )
                      : filtered.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _C.indigoSoft,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.person_search_rounded,
                                  size: 38,
                                  color: _C.indigo,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Users Found',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try a different name or filter',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: _C.textSub,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _userCard(filtered[i]),
                            childCount: filtered.length,
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

class _RoleStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  const _RoleStyle(this.color, this.bg, this.icon);
}

class _RoleFilter {
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  const _RoleFilter(this.id, this.label, this.icon, this.color, this.bg);
}
