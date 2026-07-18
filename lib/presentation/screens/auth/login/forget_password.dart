import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/api_service/auth_api.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const purple = Color(0xFF7C3AED);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const inputFill = Color(0xFFF8FAFC);
  static const inputBorder = Color(0xFFE2E8F0);
  static const rose = Color(0xFFBE123C);
  static const green = Color(0xFF16A34A);
}

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _showMessage('All fields are required', isError: true);
      return;
    }
    if (!RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$').hasMatch(email)) {
      _showMessage('Enter a valid email address', isError: true);
      return;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      _showMessage('Enter a valid 10-digit mobile number', isError: true);
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters', isError: true);
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await AuthApi.forgetPassword(
        email: email,
        mobile: mobile,
        password: password,
        confirmPassword: confirm,
      );
      final message =
          res['message']?.toString() ?? 'Password updated successfully';
      _showMessage(message, isError: false);
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      _showMessage(
        e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {required bool isError}) {
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isLandscape = mq.orientation == Orientation.landscape;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final hPad = isDesktop
        ? size.width * 0.28
        : isTablet
        ? size.width * 0.2
        : 20.0;

    return Scaffold(
      backgroundColor: _C.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _BgDecor(size: size, isTablet: isTablet),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: isLandscape ? 16 : 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLandscape) ...[
                            _LogoBlock(isTablet: isTablet),
                            SizedBox(height: isTablet ? 28 : 22),
                          ],
                          _ResetCard(
                            emailCtrl: _emailCtrl,
                            mobileCtrl: _mobileCtrl,
                            passwordCtrl: _passwordCtrl,
                            confirmCtrl: _confirmCtrl,
                            hidePassword: _hidePassword,
                            hideConfirm: _hideConfirm,
                            isLoading: _isLoading,
                            isTablet: isTablet,
                            isLandscape: isLandscape,
                            onTogglePassword: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            onToggleConfirm: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            onReset: _handleReset,
                            onBack: () => Get.back(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Drug Tracking Management System © 2026',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: _C.textSub.withValues(alpha: 0.55),
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
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
          child: _circle(isTablet ? 260 : 180, _C.indigo, 0.06),
        ),
        Positioned(
          bottom: -70,
          left: -45,
          child: _circle(isTablet ? 240 : 160, _C.purple, 0.05),
        ),
        Positioned(
          top: size.height * 0.42,
          right: -size.width * 0.28,
          child: _circle(isTablet ? 170 : 110, _C.indigo, 0.04),
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

class _LogoBlock extends StatelessWidget {
  final bool isTablet;

  const _LogoBlock({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final logoSize = isTablet ? 88.0 : 72.0;
    final iconSize = isTablet ? 44.0 : 36.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(logoSize * 0.28),
            border: Border.all(
              color: _C.indigo.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _C.indigo.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: iconSize + 14,
              height: iconSize + 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular((iconSize + 14) * 0.28),
              ),
              child: Icon(
                Icons.local_pharmacy_rounded,
                size: iconSize * 0.78,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Drug ',
                style: GoogleFonts.nunito(
                  color: _C.textPrimary,
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              TextSpan(
                text: 'Tracking',
                style: GoogleFonts.nunito(
                  color: _C.indigo,
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Management System',
          style: GoogleFonts.nunito(
            color: _C.textSub,
            fontSize: isTablet ? 12.0 : 11.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _ResetCard extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController mobileCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool hidePassword;
  final bool hideConfirm;
  final bool isLoading;
  final bool isTablet;
  final bool isLandscape;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onReset;
  final VoidCallback onBack;

  const _ResetCard({
    required this.emailCtrl,
    required this.mobileCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.hidePassword,
    required this.hideConfirm,
    required this.isLoading,
    required this.isTablet,
    required this.isLandscape,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onReset,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.indigo.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: _C.indigo.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 28 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLandscape) ...[
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Drug ',
                          style: GoogleFonts.nunito(
                            color: _C.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: 'Tracking',
                          style: GoogleFonts.nunito(
                            color: _C.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Reset Password',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _C.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                'Verify your identity and set a new password',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: _C.textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.indigo.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: _C.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter your registered email and mobile to verify your account',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: _C.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _field(
              label: 'Email Address',
              ctrl: emailCtrl,
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _field(
              label: 'Mobile Number',
              ctrl: mobileCtrl,
              hint: '9XXXXXXXXX',
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
              action: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 14),
            _passwordField(
              label: 'New Password',
              ctrl: passwordCtrl,
              hint: '••••••••',
              hidden: hidePassword,
              onToggle: onTogglePassword,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            _passwordField(
              label: 'Confirm New Password',
              ctrl: confirmCtrl,
              hint: '••••••••',
              hidden: hideConfirm,
              onToggle: onToggleConfirm,
              action: TextInputAction.done,
              onSubmit: (_) => onReset(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _C.indigo.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Update Password',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: _C.divider, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Remembered it?',
                    style: GoogleFonts.nunito(
                      color: _C.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: _C.divider, thickness: 1)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.indigo,
                  side: BorderSide(
                    color: _C.indigo.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _C.indigo,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: GoogleFonts.nunito(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: _C.textPrimary,
    ),
  );

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required TextInputType inputType,
    required TextInputAction action,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: inputType,
          textInputAction: action,
          inputFormatters: inputFormatters,
          autocorrect: false,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
          decoration: _inputDecor(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required bool hidden,
    required VoidCallback onToggle,
    required TextInputAction action,
    ValueChanged<String>? onSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: hidden,
          textInputAction: action,
          onSubmitted: onSubmit,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.textPrimary,
          ),
          decoration: _inputDecor(
            hint: hint,
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _C.textSub,
                size: 20,
              ),
              onPressed: onToggle,
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(
        color: _C.textSub.withValues(alpha: 0.5),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _C.textSub, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _C.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
