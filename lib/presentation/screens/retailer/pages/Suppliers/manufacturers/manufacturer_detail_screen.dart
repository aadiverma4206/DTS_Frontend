import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../retailer/controller/manufacturer_detail_controller.dart';

class ManufacturerDetailScreen extends StatelessWidget {
  final int manufacturerId;

  const ManufacturerDetailScreen({super.key, required this.manufacturerId});

  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF034A17);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);
  static const Color _acceptColor = Color(0xFF00B87A);
  static const Color _acceptBg = Color(0xFFE6F9F2);
  static const Color _pendingColor = Color(0xFFF59E0B);
  static const Color _pendingBg = Color(0xFFFFF8EC);

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor.withOpacity(0.75)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.inter(
            color: _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value,
    Color color,
    Color bg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
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
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? "-" : value,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManufacturerDetailController(manufacturerId));
    final width = MediaQuery.of(context).size.width;
    final double horizontalPad = width > 900
        ? width * 0.18
        : width > 600
        ? width * 0.08
        : 16;

    return Scaffold(
      backgroundColor: _bg,
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
          "Manufacturer Details",
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            height: 28,
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 30),
            children: const [_BlinkingSkeletonDetail()],
          );
        }

        if (controller.manufacturer.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _purpleSoft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      size: 40,
                      color: _purple.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No data found",
                    style: GoogleFonts.spaceGrotesk(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final manufacturer = controller.manufacturer;
        final name = controller.value(manufacturer["company_name"]);
        final dl = controller.value(manufacturer["drug_license_no"]);
        final gstin = controller.value(manufacturer["gstin"]);
        final phone = controller.value(manufacturer["phone"]);
        final email = controller.value(manufacturer["email"]);
        final website = controller.value(manufacturer["website"]);
        final address = controller.value(manufacturer["address"]);
        final initial = name.isNotEmpty
            ? name.substring(0, 1).toUpperCase()
            : "M";

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _cardShadow,
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
                        color: _purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.spaceGrotesk(
                            color: _purple,
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
                      style: GoogleFonts.spaceGrotesk(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (phone.isNotEmpty && phone != "-") ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: GoogleFonts.inter(
                              color: _textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                Icons.verified_rounded,
                "Drug License No.",
                dl,
                _purple,
                _purpleSoft,
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                Icons.receipt_rounded,
                "GSTIN",
                gstin,
                _acceptColor,
                _acceptBg,
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                Icons.phone_rounded,
                "Phone",
                phone,
                _pendingColor,
                _pendingBg,
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                Icons.email_rounded,
                "Email",
                email,
                _purple,
                _purpleSoft,
              ),
              if (website.isNotEmpty && website != "-") ...[
                const SizedBox(height: 10),
                _buildInfoCard(
                  Icons.language_rounded,
                  "Website",
                  website,
                  _acceptColor,
                  _acceptBg,
                ),
              ],
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _pendingBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: _pendingColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address",
                            style: GoogleFonts.inter(
                              color: _textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            address.isEmpty ? "-" : address,
                            style: GoogleFonts.inter(
                              color: _textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: _divider),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _purpleSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "PURCHASED DRUGS",
                      style: GoogleFonts.inter(
                        color: _purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${controller.drugs.length} drug${controller.drugs.length != 1 ? "s" : ""}",
                    style: GoogleFonts.inter(
                      color: _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              controller.drugs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: _purpleSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              size: 34,
                              color: _purple.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No drugs found",
                            style: GoogleFonts.spaceGrotesk(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.drugs.length,
                      itemBuilder: (context, index) {
                        final drug = controller.drugs[index];
                        final drugName = drug["drug_name"]?.toString() ?? "";
                        final strength = drug["strength"]?.toString() ?? "";
                        final dosageForm =
                            drug["dosage_form"]?.toString() ?? "";
                        final subtitle = [
                          strength,
                          dosageForm,
                        ].where((s) => s.isNotEmpty).join(" ");

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _divider, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: _cardShadow,
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
                                  color: _purpleSoft,
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
                                        color: _purple.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.medication_rounded,
                                        color: _purple,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        drugName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: _textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (subtitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    10,
                                    16,
                                    12,
                                  ),
                                  child: _buildDetailRow(
                                    Icons.science_rounded,
                                    "Form",
                                    subtitle,
                                    _acceptColor,
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
}

class _BlinkingSkeletonDetail extends StatefulWidget {
  const _BlinkingSkeletonDetail();

  @override
  State<_BlinkingSkeletonDetail> createState() =>
      _BlinkingSkeletonDetailState();
}

class _BlinkingSkeletonDetailState extends State<_BlinkingSkeletonDetail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
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
        color: const Color(0xFFE5E0F5).withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerCardRow() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E0F5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14602EE8),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _shimmerBox(width: 40, height: 40, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 70, height: 11),
                const SizedBox(height: 6),
                _shimmerBox(width: 160, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_animation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E0F5), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14602EE8),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _shimmerBox(width: 72, height: 72, radius: 22),
                const SizedBox(height: 12),
                _shimmerBox(width: 180, height: 20),
                const SizedBox(height: 8),
                _shimmerBox(width: 110, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _shimmerCardRow(),
          _shimmerCardRow(),
          _shimmerCardRow(),
          _shimmerCardRow(),
          _shimmerCardRow(),
          const SizedBox(height: 14),
          _shimmerBox(width: 130, height: 20, radius: 8),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E0F5), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14602EE8),
                  blurRadius: 14,
                  offset: Offset(0, 4),
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
                    color: Color(0xFFEDE8FB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      _shimmerBox(width: 46, height: 46, radius: 14),
                      const SizedBox(width: 12),
                      _shimmerBox(width: 130, height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      _shimmerBox(width: 14, height: 14, radius: 4),
                      const SizedBox(width: 8),
                      _shimmerBox(width: 150, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
