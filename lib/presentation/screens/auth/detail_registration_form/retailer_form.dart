import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/api_service/form/retailer_form_api.dart';
// import '../../retailer/retailer_home.dart';
import '../../retailer/retailer_home.dart';
import '../login/auth_storage.dart';
import '../login/logout_system.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const purple = Color(0xFF7C3AED);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const inputFill = Color(0xFFF8FAFC);
  static const inputBorder = Color(0xFFE2E8F0);
  static const rose = Color(0xFFBE123C);
  static const roseSoft = Color(0xFFFFE4E6);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
}

class RetailerForm extends StatefulWidget {
  const RetailerForm({super.key});

  @override
  State<RetailerForm> createState() => _RetailerFormState();
}

class _RetailerFormState extends State<RetailerForm>
    with SingleTickerProviderStateMixin {
  final _shopNameCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

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
    _shopNameCtrl.dispose();
    _gstinCtrl.dispose();
    _licenseCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    final shopName = _shopNameCtrl.text.trim();
    final gstin = _gstinCtrl.text.trim();
    final license = _licenseCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (shopName.isEmpty) {
      _showMsg('Shop name is required', isError: true);
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
    if (phone.isEmpty) {
      _showMsg('Phone number is required', isError: true);
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showMsg('Enter a valid 10-digit phone number', isError: true);
      return;
    }
    if (email.isEmpty) {
      _showMsg('Email is required', isError: true);
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showMsg('Enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await RetailerFormApi.createRetailer(
        shopName: shopName,
        gstin: gstin,
        drugLicenseNo: license,
        address: address,
        phone: phone,
        email: email,
      );
      if (!mounted) return;
      _showMsg(
        response['message']?.toString() ?? 'Retailer profile created',
        isError: false,
      );await AuthStorage.setProfileCompleted(true);
      Get.offAll(() => const RetailerHome());
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
                          const SizedBox(height: 14),
                          _logoutCard(),
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
        'Retailer Profile',
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
              onPressed: () => Navigator.pop(context),
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
          colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.indigo.withValues(alpha: 0.3),
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
              Icons.store_rounded,
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
                  'Setup Retailer Profile',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Complete your shop details to get started',
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
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  'RETAILER',
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
        border: Border.all(color: _C.indigo.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: _C.indigo.withValues(alpha: 0.07),
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
            _sectionHeader(
              icon: Icons.store_rounded,
              iconColor: _C.indigo,
              iconBg: _C.indigoSoft,
              title: 'Shop Information',
              subtitle: 'All fields are required',
            ),
            const SizedBox(height: 18),
            _field(
              label: 'Shop Name',
              ctrl: _shopNameCtrl,
              hint: 'e.g. Sharma Medical Store',
              icon: Icons.store_outlined,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _field(
              label: 'GSTIN',
              ctrl: _gstinCtrl,
              hint: 'e.g. 27AAPFU0939F1ZV',
              icon: Icons.receipt_long_outlined,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            const SizedBox(height: 14),
            _field(
              label: 'Drug License Number',
              ctrl: _licenseCtrl,
              hint: 'e.g. DL-MH-123456',
              icon: Icons.verified_outlined,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                LengthLimitingTextInputFormatter(30),
              ],
            ),
            const SizedBox(height: 14),
            _field(
              label: 'Address',
              ctrl: _addressCtrl,
              hint: 'Shop full address',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            _field(
              label: 'Email',
              ctrl: _emailCtrl,
              hint: 'shop@example.com',
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
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
              borderSide: const BorderSide(color: _C.indigo, width: 1.8),
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
          backgroundColor: _C.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.indigo.withValues(alpha: 0.5),
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
                    'Submit Profile',
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

  Widget _logoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.rose.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _C.rose.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => LogoutSystem.logout(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _C.roseSoft,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: _C.rose.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: _C.rose,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _C.rose,
                        ),
                      ),
                      Text(
                        'Sign out from your account',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _C.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _C.rose.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
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
          child: _circle(isTablet ? 240 : 160, _C.indigo, 0.05),
        ),
        Positioned(
          bottom: -60,
          left: -40,
          child: _circle(isTablet ? 220 : 150, _C.purple, 0.04),
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
