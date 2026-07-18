import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/api_service/form/manufacturer_form_api.dart';

class _C {
  static const bg = Color(0xFFF4F2FB);
  static const surface = Color(0xFFFFFFFF);
  static const purple = Color(0xFF5C35D4);
  static const purpleSoft = Color(0xFFEDE8FB);
  static const textPrimary = Color(0xFF1A1035);
  static const textSub = Color(0xFF7B7494);
  static const inputBorder = Color(0xFFD4C8F7);
  static const inputFill = Color(0xFFF8F6FE);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
}

class ManufacturerForm extends StatefulWidget {
  const ManufacturerForm({super.key});

  @override
  State<ManufacturerForm> createState() => _ManufacturerFormState();
}

class _ManufacturerFormState extends State<ManufacturerForm>
    with SingleTickerProviderStateMixin {
  final _companyCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _productInfoCtrl = TextEditingController();

  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _companyCtrl.dispose();
    _gstinCtrl.dispose();
    _licenseCtrl.dispose();
    _panCtrl.dispose();
    _cinCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _productInfoCtrl.dispose();
    super.dispose();
  }

  void _clearFields() {
    _companyCtrl.clear();
    _gstinCtrl.clear();
    _licenseCtrl.clear();
    _panCtrl.clear();
    _cinCtrl.clear();
    _addressCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _websiteCtrl.clear();
    _productInfoCtrl.clear();
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    final company = _companyCtrl.text.trim();
    final gstin = _gstinCtrl.text.trim();
    final license = _licenseCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final pan = _panCtrl.text.trim();
    final cin = _cinCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final website = _websiteCtrl.text.trim();
    final productInfo = _productInfoCtrl.text.trim();

    if (company.isEmpty) {
      _showMsg('Company name is required', isError: true);
      return;
    }
    if (gstin.isEmpty) {
      _showMsg('GSTIN is required', isError: true);
      return;
    }
    if (!RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$',
    ).hasMatch(gstin)) {
      _showMsg('Enter a valid GSTIN', isError: true);
      return;
    }
    if (license.isEmpty) {
      _showMsg('Drug license number is required', isError: true);
      return;
    }
    if (address.isEmpty) {
      _showMsg('Address is required', isError: true);
      return;
    }
    if (phone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMsg('Enter a valid 10-digit phone number', isError: true);
      return;
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showMsg('Enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ManufacturerFormApi.createManufacturer(
        companyName: company,
        gstin: gstin,
        drugLicenseNo: license,
        address: address,
        panNo: pan.isEmpty ? null : pan,
        cinNo: cin.isEmpty ? null : cin,
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
        website: website.isEmpty ? null : website,
        productInfo: productInfo.isEmpty ? null : productInfo,
      );
      if (!mounted) return;
      _showMsg(
        response['message']?.toString() ?? 'Manufacturer added successfully',
        isError: false,
      );
      _clearFields();
      Get.back();
    } catch (e) {
      if (!mounted) return;
      _showMsg(e.toString().replaceAll('Exception:', '').trim(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? _C.rose.withValues(alpha: 0.95)
          : _C.green.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(14),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  double _hPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1024) return w * 0.28;
    if (w > 600) return w * 0.12;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width > 600;
    final isLandscape = mq.orientation == Orientation.landscape;
    final hp = _hPad(context);

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _BgDecor(size: mq.size, isTablet: isTablet),
          SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      hp,
                      isLandscape ? 16 : 20,
                      hp,
                      32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _headerBanner(isTablet),
                          SizedBox(height: isTablet ? 20 : 16),
                          _formCard(isTablet),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Drug Tracking Management System © 2026',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: _C.textSub.withValues(alpha: 0.55),
                                fontSize: isTablet ? 12 : 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.deepPurple,
      centerTitle: true,
      title: Text(
        'Add Manufacturer',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            )
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          height: 20,
          decoration: const BoxDecoration(color: _C.bg),
        ),
      ),
    );
  }

  Widget _headerBanner(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C35D4), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52 : 44,
            height: isTablet ? 52 : 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.factory_rounded,
              color: Colors.white,
              size: isTablet ? 26 : 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Manufacturer',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Fill in the manufacturer details below',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  'MFR',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.purple.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Information
            _sectionHeader(
              icon: Icons.business_rounded,
              iconColor: _C.purple,
              iconBg: _C.purpleSoft,
              title: 'Company Information',
              subtitle: '* Required fields',
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Company Name',
              ctrl: _companyCtrl,
              hint: 'e.g. Sun Pharma Ltd.',
              icon: Icons.business_outlined,
              isRequired: true,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'GSTIN',
              ctrl: _gstinCtrl,
              hint: 'e.g. 27AAPFU0939F1ZV',
              icon: Icons.receipt_long_outlined,
              isRequired: true,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Drug License No',
              ctrl: _licenseCtrl,
              hint: 'e.g. MFG-MH-123456',
              icon: Icons.verified_outlined,
              isRequired: true,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'PAN No',
              ctrl: _panCtrl,
              hint: 'e.g. AAPFU0939F',
              icon: Icons.credit_card_outlined,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              label: 'CIN No',
              ctrl: _cinCtrl,
              hint: 'e.g. U24230MH2000PLC123456',
              icon: Icons.confirmation_number_outlined,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                LengthLimitingTextInputFormatter(21),
              ],
            ),

            const SizedBox(height: 20),
            _divider(),
            const SizedBox(height: 16),

            // Location
            _sectionHeader(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF0891B2),
              iconBg: const Color(0xFFE0F7FA),
              title: 'Location',
              subtitle: 'Shop / office address',
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Address',
              ctrl: _addressCtrl,
              hint: 'Full company address',
              icon: Icons.location_on_outlined,
              isRequired: true,
              maxLines: 3,
              action: TextInputAction.next,
            ),

            const SizedBox(height: 20),
            _divider(),
            const SizedBox(height: 16),

            // Contact Details
            _sectionHeader(
              icon: Icons.contact_phone_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFD1FAE5),
              title: 'Contact Details',
              subtitle: 'Optional but recommended',
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Phone',
              ctrl: _phoneCtrl,
              hint: 'e.g. 9876543210',
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Email',
              ctrl: _emailCtrl,
              hint: 'company@example.com',
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Website',
              ctrl: _websiteCtrl,
              hint: 'https://example.com',
              icon: Icons.language_outlined,
              inputType: TextInputType.url,
              action: TextInputAction.next,
            ),

            const SizedBox(height: 20),
            _divider(),
            const SizedBox(height: 16),

            // Product Details
            _sectionHeader(
              icon: Icons.inventory_2_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFEF3C7),
              title: 'Product Details',
              subtitle: 'Optional',
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Product Info',
              ctrl: _productInfoCtrl,
              hint: 'Describe manufactured products...',
              icon: Icons.inventory_2_outlined,
              maxLines: 3,
              action: TextInputAction.done,
              onSubmit: (_) => _submitForm(),
            ),

            const SizedBox(height: 24),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, _C.inputBorder, Colors.transparent],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textSub,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _C.rose,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: inputType,
          textInputAction: action,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmit,
          autocorrect: false,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(
              color: _C.textSub.withValues(alpha: 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: _C.textSub, size: 20),
            filled: true,
            fillColor: _C.inputFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.purple, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.rose, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.rose, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.purple.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
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
                  const Icon(Icons.check_circle_outline_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Submit',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BgDecor extends StatelessWidget {
  final Size size;
  final bool isTablet;

  const _BgDecor({required this.size, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -55,
          right: -55,
          child: _circle(isTablet ? 240 : 160, _C.purple, 0.05),
        ),
        Positioned(
          bottom: -60,
          left: -40,
          child: _circle(isTablet ? 220 : 150, const Color(0xFF9B59B6), 0.04),
        ),
      ],
    );
  }

  Widget _circle(double d, Color c, double o) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: c.withValues(alpha: o),
    ),
  );
}
