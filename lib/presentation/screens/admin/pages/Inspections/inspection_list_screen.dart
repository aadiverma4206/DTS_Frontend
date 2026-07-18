import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drug_tracking_system/core/services/api_service/inspection_api.dart';
import 'inspection_detail_admin.dart';

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

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen>
    with SingleTickerProviderStateMixin {
  bool _isOverviewLoading = true;
  bool _isListLoading = true;
  bool _isListReloading = false;

  List<Map<String, dynamic>> _allInspections = [];
  List<Map<String, String>> _inspectorList = [
    {'id': 'all', 'name': 'All Inspectors'},
  ];

  String _selectedInspectorId = 'all';
  String _selectedInspectorName = 'All Inspectors';
  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _searchQuery = '';

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  int _totalCount = 0;
  int _verifiedCount = 0;
  int _pendingCount = 0;
  int _discrepancyCount = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _statusOptions = [
    {'key': 'all', 'label': 'All', 'color': _C.indigo, 'bg': _C.indigoSoft},
    {
      'key': 'verified',
      'label': 'Verified',
      'color': _C.green,
      'bg': _C.greenSoft,
    },
    {
      'key': 'discrepancy',
      'label': 'Discrepancy',
      'color': _C.rose,
      'bg': _C.roseSoft,
    },
    {
      'key': 'pending',
      'label': 'Pending',
      'color': _C.amber,
      'bg': _C.amberSoft,
    },
    {
      'key': 'in_progress',
      'label': 'In Progress',
      'color': _C.blue,
      'bg': _C.blueSoft,
    },
    {
      'key': 'completed',
      'label': 'Completed',
      'color': _C.purple,
      'bg': _C.purpleSoft,
    },
    {
      'key': 'rejected',
      'label': 'Rejected',
      'color': _C.slate,
      'bg': _C.slateSoft,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = val.trim());
    });
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _isOverviewLoading = true;
      _isListLoading = true;
    });
    try {
      final data = await InspectionApi.getAllInspections(
        inspectorId: _selectedInspectorId,
        targetType: _typeFilter,
        search: _searchQuery,
      );
      if (!mounted) return;
      _processData(data);
      setState(() {
        _isOverviewLoading = false;
        _isListLoading = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isOverviewLoading = false;
        _isListLoading = false;
      });
    }
  }

  Future<void> _reloadList() async {
    if (!mounted) return;
    if (_isListReloading) return;
    setState(() => _isListReloading = true);
    try {
      final data = await InspectionApi.getAllInspections(
        inspectorId: _selectedInspectorId,
        targetType: _typeFilter,
        search: _searchQuery,
      );
      if (!mounted) return;
      _processData(data);
      setState(() {});
      _fadeCtrl.forward(from: 0);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isListReloading = false);
  }

  void _processData(List<Map<String, dynamic>> data) {
    final Map<String, String> inspMap = {};
    for (final item in data) {
      final id = item['inspector_id']?.toString() ?? '';
      final name = item['inspector_name']?.toString() ?? '';
      if (id.isNotEmpty && name.isNotEmpty) inspMap[id] = name;
    }
    final List<Map<String, String>> list = [
      {'id': 'all', 'name': 'All Inspectors'},
    ];
    inspMap.forEach((id, name) => list.add({'id': id, 'name': name}));

    if (!list.any((e) => e['id'] == _selectedInspectorId)) {
      _selectedInspectorId = 'all';
      _selectedInspectorName = 'All Inspectors';
    }

    _allInspections = data;
    _inspectorList = list;
    _totalCount = data.length;
    _verifiedCount = data.where((e) => e['status'] == 'verified').length;
    _pendingCount = data.where((e) => e['status'] == 'pending').length;
    _discrepancyCount = data.where((e) => e['status'] == 'discrepancy').length;
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _allInspections.where((item) {
      final name = (item['target_name'] ?? '').toString().toLowerCase();
      final type = (item['inspection_type'] ?? '').toString().toLowerCase();
      final status = (item['status'] ?? '').toString().toLowerCase();
      final inspId = (item['inspector_id'] ?? '').toString();

      final matchSearch = q.isEmpty || name.contains(q);
      final matchType = _typeFilter == 'all' || type == _typeFilter;
      final matchStatus = _statusFilter == 'all' || status == _statusFilter;
      final matchInspector =
          _selectedInspectorId == 'all' || inspId == _selectedInspectorId;

      return matchSearch && matchType && matchStatus && matchInspector;
    }).toList();
  }

  Map<String, dynamic> _statusMeta(String status) {
    return _statusOptions.firstWhere(
      (s) => s['key'] == status,
      orElse: () => {'color': _C.slate, 'bg': _C.slateSoft, 'label': status},
    );
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

  void _openInspectorBottomSheet() {
    final TextEditingController sheetSearch = TextEditingController();
    List<Map<String, String>> sheetFiltered = List.from(_inspectorList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void onSearch(String val) {
              final q = val.trim().toLowerCase();
              setSheetState(() {
                sheetFiltered = _inspectorList
                    .where(
                      (e) =>
                          q.isEmpty ||
                          (e['name'] ?? '').toLowerCase().contains(q),
                    )
                    .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _C.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
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
                            'Select Inspector',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _C.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _C.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _C.divider),
                        ),
                        child: TextField(
                          controller: sheetSearch,
                          onChanged: onSearch,
                          autofocus: false,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search inspector...',
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                      ),
                      child: sheetFiltered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No inspector found',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: _C.textSub,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: sheetFiltered.length,
                              itemBuilder: (_, i) {
                                final insp = sheetFiltered[i];
                                final isSelected =
                                    insp['id'] == _selectedInspectorId;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedInspectorId =
                                          insp['id'] ?? 'all';
                                      _selectedInspectorName =
                                          insp['name'] ?? 'All Inspectors';
                                    });
                                    Navigator.pop(ctx);
                                    _reloadList();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
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
                                              (insp['name'] ?? 'A')[0]
                                                  .toUpperCase(),
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
                                            insp['name'] ?? '',
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
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      margin: const EdgeInsets.only(bottom: 10),
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
          _skeletonBox(width: 46, height: 46, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 140, height: 14),
                const SizedBox(height: 8),
                _skeletonBox(width: 100, height: 11),
                const SizedBox(height: 8),
                _skeletonBox(width: 120, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _skeletonBox(width: 70, height: 26, radius: 10),
                const SizedBox(height: 8),
                _skeletonBox(width: 30, height: 30, radius: 9),
              ],
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
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
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

  Widget _inspectorSelector() {
    return GestureDetector(
      onTap: _openInspectorBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.indigoSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: _C.indigo,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedInspectorName,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
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

  Widget _typeFilterRow() {
    final typeOptions = [
      {
        'key': 'all',
        'label': 'All',
        'icon': Icons.apps_rounded,
        'color': _C.indigo,
      },
      {
        'key': 'retailer',
        'label': 'Retailer',
        'icon': Icons.store_rounded,
        'color': _C.green,
      },
      {
        'key': 'wholesaler',
        'label': 'Wholesaler',
        'icon': Icons.warehouse_rounded,
        'color': _C.blue,
      },
    ];
    return Row(
      children: List.generate(typeOptions.length, (index) {
        final opt = typeOptions[index];
        final sel = _typeFilter == opt['key'];
        final color = opt['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final newType = opt['key'] as String;
              if (_typeFilter == newType) return;
              setState(() => _typeFilter = newType);
              _reloadList();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: index < typeOptions.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: sel ? color : _C.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? color : _C.divider),
                boxShadow: [
                  BoxShadow(
                    color: sel ? color.withValues(alpha: 0.18) : _C.shadow,
                    blurRadius: sel ? 10 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 15,
                    color: sel ? Colors.white : color,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      opt['label'] as String,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : _C.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _statusFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _statusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final opt = _statusOptions[i];
          final sel = _statusFilter == opt['key'];
          final color = opt['color'] as Color;
          return GestureDetector(
            onTap: () {
              final newStatus = opt['key'] as String;
              if (_statusFilter == newStatus) return;
              setState(() => _statusFilter = newStatus);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? color : _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? color : _C.divider),
                boxShadow: [
                  BoxShadow(
                    color: sel ? color.withValues(alpha: 0.2) : _C.shadow,
                    blurRadius: sel ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                opt['label'] as String,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : _C.textSub,
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
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search retailer or wholesaler...',
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
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
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

  Widget _inspectionCard(Map<String, dynamic> item) {
    final int id = int.tryParse(item['inspection_id']?.toString() ?? '0') ?? 0;
    final String status = item['status']?.toString() ?? '';
    final String name = item['target_name']?.toString() ?? 'Unknown';
    final String inspector = item['inspector_name']?.toString() ?? '';
    final String date = _formatDate(item['inspection_date']?.toString());
    final String type = (item['inspection_type'] ?? '').toString();
    final int totalSystem =
        int.tryParse(item['total_system_qty']?.toString() ?? '0') ?? 0;
    final int totalPhysical =
        int.tryParse(item['total_physical_qty']?.toString() ?? '0') ?? 0;
    final bool mismatch = totalSystem != totalPhysical;
    final meta = _statusMeta(status);
    final Color statusColor = meta['color'] as Color;
    final Color statusBg = meta['bg'] as Color;
    final String statusLabel = meta['label'] as String;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isRetailer = type == 'retailer';
    final typeColor = isRetailer ? _C.green : _C.blue;
    final typeBg = isRetailer ? _C.greenSoft : _C.blueSoft;
    final typeLabel = type.isNotEmpty
        ? type[0].toUpperCase() + type.substring(1)
        : '';

    return RepaintBoundary(
      child: GestureDetector(
        onTap: id == 0
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InspectionDetailAdmin(inspectionId: id),
                ),
              ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                  child: Text(
                    initial,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _C.textPrimary,
                      ),
                    ),
                    if (inspector.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 11,
                            color: _C.textSub,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              inspector,
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
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: _C.textSub,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              date.isNotEmpty ? date : 'No date',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: _C.textSub,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (typeLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              typeLabel,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mismatch
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_rounded,
                          size: 12,
                          color: mismatch ? _C.rose : _C.green,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Sys: $totalSystem  •  Phy: $totalPhysical',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: mismatch ? _C.rose : _C.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 76,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _C.indigoSoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: _C.indigo,
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

  Widget _emptyState() {
    return SliverFillRemaining(
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
              Icons.assignment_late_rounded,
              size: 38,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Inspections Found',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters or search',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: _C.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  SliverList _skeletonSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => _skeletonCard(),
        childCount: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hp = _hPad;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          'Inspections',
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
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('Overview'),
                    _isOverviewLoading
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(4, (_) {
                              final cardW =
                                  (MediaQuery.of(context).size.width -
                                      hp * 2 -
                                      30) /
                                  4;
                              return SizedBox(
                                width: cardW.clamp(60.0, 200.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _C.divider),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: _C.divider,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 30,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: _C.divider,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _overviewCard(
                                  'Total',
                                  '$_totalCount',
                                  Icons.assignment_rounded,
                                  _C.indigo,
                                  _C.indigoSoft,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _overviewCard(
                                  'Verified',
                                  '$_verifiedCount',
                                  Icons.verified_rounded,
                                  _C.green,
                                  _C.greenSoft,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _overviewCard(
                                  'Pending',
                                  '$_pendingCount',
                                  Icons.hourglass_top_rounded,
                                  _C.amber,
                                  _C.amberSoft,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _overviewCard(
                                  'Issues',
                                  '$_discrepancyCount',
                                  Icons.warning_amber_rounded,
                                  _C.rose,
                                  _C.roseSoft,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    _sectionLabel('Inspector'),
                    _inspectorSelector(),
                    const SizedBox(height: 14),
                    _sectionLabel('Type'),
                    _typeFilterRow(),
                    const SizedBox(height: 14),
                    _sectionLabel('Status'),
                    _statusFilterRow(),
                    const SizedBox(height: 14),
                    _sectionLabel('Search'),
                    _searchField(),
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
                        const Spacer(),
                        GestureDetector(
                          onTap: _isListReloading ? null : _reloadList,
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
                                if (_isListReloading)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: _C.indigo,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(
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
                    const SizedBox(height: 10),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hp, 0, hp, 20),
                sliver: _isListLoading
                    ? _skeletonSliver()
                    : filtered.isEmpty
                    ? _emptyState()
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _inspectionCard(filtered[i]),
                          childCount: filtered.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
