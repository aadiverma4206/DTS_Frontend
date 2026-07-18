import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/retailer_detail_controller.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const blue = Color(0xFF0369A1);
  static const blueSoft = Color(0xFFE0F2FE);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const amber = Color(0xFFB45309);
  static const amberSoft = Color(0xFFFEF3C7);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const teal = Color(0xFF0F766E);
  static const tealSoft = Color(0xFFCCFBF1);
  static const purple = Color(0xFF7E22CE);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A4338CA);
}

class RetailerDetailScreen extends StatelessWidget {
  final int retailerId;

  const RetailerDetailScreen({super.key, required this.retailerId});

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return w * 0.20;
    if (w > 700) return w * 0.08;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RetailerDetailController(retailerId));
    final hPad = _hPad(context);

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Retailer Details',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
      body: SafeArea(child: Obx(() => _buildBody(context, controller, hPad))),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RetailerDetailController controller,
    double hPad,
  ) {
    if (controller.isLoading.value) {
      return Padding(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
        child: const _SkeletonDetails(),
      );
    }

    if (controller.retailer.isEmpty) {
      return _emptyView();
    }

    final r = controller.retailer;
    final name = controller.value(r['name']);
    final shop = controller.value(r['shop_name']);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';
    final status = controller.value(r['status']).toLowerCase();
    final isActive =
        status == 'active' || status == '1' || status == 'approved';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileCard(initial, name, shop),
          const SizedBox(height: 16),
          _sectionLabel('Contact Information'),
          const SizedBox(height: 10),
          _infoCard(
            children: [
              _infoRow(
                Icons.person_outline_rounded,
                'Retailer Name',
                name,
                _C.indigo,
                _C.indigoSoft,
              ),
              _infoRow(
                Icons.phone_outlined,
                'Phone',
                controller.value(r['phone']),
                _C.green,
                _C.greenSoft,
              ),
              _infoRow(
                Icons.smartphone_outlined,
                'Mobile',
                controller.value(r['mobile']),
                _C.teal,
                _C.tealSoft,
              ),
              _infoRow(
                Icons.email_outlined,
                'Email',
                controller.value(r['email']),
                _C.blue,
                _C.blueSoft,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel('Business Information'),
          const SizedBox(height: 10),
          _infoCard(
            children: [
              _infoRow(
                Icons.storefront_outlined,
                'Shop Name',
                shop,
                _C.green,
                _C.greenSoft,
              ),
              _infoRow(
                Icons.badge_outlined,
                'Drug License No',
                controller.value(r['drug_license_no']),
                _C.teal,
                _C.tealSoft,
              ),
              _infoRow(
                Icons.verified_user_outlined,
                'GSTIN',
                controller.value(r['gstin']),
                _C.purple,
                _C.purpleSoft,
              ),
              _infoRow(
                Icons.location_on_outlined,
                'Address',
                controller.value(r['address']),
                _C.amber,
                _C.amberSoft,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel('Account Status'),
          const SizedBox(height: 10),
          _infoCard(
            children: [_statusRow(isActive, controller.value(r['status']))],
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String initial, String name, String shop) {
    return Container(
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _C.greenSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _C.green,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: _C.green.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name.isEmpty ? 'Unknown' : name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                if (shop.isNotEmpty && shop != '-') ...[
                  const SizedBox(height: 4),
                  Text(
                    shop,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _C.textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'RETAILER',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _sectionLabel(String text) {
    return Row(
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
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, color: _C.divider),
            ],
          );
        }),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color fg,
    Color bg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: fg),
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
                    fontWeight: FontWeight.w600,
                    color: _C.textSub,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
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

  Widget _statusRow(bool isActive, String rawStatus) {
    final color = isActive ? _C.green : _C.amber;
    final bg = isActive ? _C.greenSoft : _C.amberSoft;
    final label = rawStatus.isEmpty
        ? '-'
        : rawStatus[0].toUpperCase() + rawStatus.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_rounded, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.textSub,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
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
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.indigoSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_off_rounded,
              size: 30,
              color: _C.indigo,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Data Found',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonDetails extends StatefulWidget {
  const _SkeletonDetails();

  @override
  State<_SkeletonDetails> createState() => _SkeletonDetailsState();
}

class _SkeletonDetailsState extends State<_SkeletonDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _C.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 36, height: 36, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 80, height: 11, radius: 4),
                const SizedBox(height: 6),
                _shimmerBox(width: 150, height: 14, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard({required int itemCount}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: List.generate(itemCount, (i) {
          return Column(
            children: [
              _shimmerRow(),
              if (i < itemCount - 1)
                const Divider(height: 1, color: _C.divider),
            ],
          );
        }),
      ),
    );
  }

  Widget _shimmerSectionLabel() {
    return Row(
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
        _shimmerBox(width: 120, height: 14, radius: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_anim),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _C.divider),
                boxShadow: const [
                  BoxShadow(
                    color: _C.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: _C.greenSoft,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        _shimmerBox(width: 72, height: 72, radius: 22),
                        const SizedBox(height: 14),
                        _shimmerBox(width: 160, height: 18, radius: 4),
                        const SizedBox(height: 8),
                        _shimmerBox(width: 110, height: 12, radius: 4),
                        const SizedBox(height: 12),
                        _shimmerBox(width: 80, height: 22, radius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _shimmerSectionLabel(),
            const SizedBox(height: 10),
            _shimmerCard(itemCount: 4),
            const SizedBox(height: 16),
            _shimmerSectionLabel(),
            const SizedBox(height: 10),
            _shimmerCard(itemCount: 4),
            const SizedBox(height: 16),
            _shimmerSectionLabel(),
            const SizedBox(height: 10),
            _shimmerCard(itemCount: 1),
          ],
        ),
      ),
    );
  }
}
