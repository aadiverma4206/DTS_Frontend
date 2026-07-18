import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/login_controller.dart';
import 'forget_password.dart';
import '../register/register_screen.dart';

class _C {
  static const bg = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4338CA);
  static const indigoSoft = Color(0xFFEEF2FF);
  static const indigoDark = Color(0xFF3730A3);
  static const purple = Color(0xFF7C3AED);
  static const textPrimary = Color(0xFF0F172A);
  static const textSub = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const inputFill = Color(0xFFF8FAFC);
  static const inputBorder = Color(0xFFE2E8F0);
  static const rose = Color(0xFFBE123C);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginController _controller;
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

    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }
    _controller = Get.put(LoginController());

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
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
                          _LoginCard(
                            controller: _controller,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isTablet: isTablet,
                            isLandscape: isLandscape,
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

class _LoginCard extends StatelessWidget {
  final LoginController controller;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isTablet;
  final bool isLandscape;

  const _LoginCard({
    required this.controller,
    required this.emailController,
    required this.passwordController,
    required this.isTablet,
    required this.isLandscape,
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
            _cardHeader(),
            const SizedBox(height: 22),
            _fieldLabel('Email Address'),
            const SizedBox(height: 6),
            _emailField(),
            const SizedBox(height: 16),
            _fieldLabel('Password'),
            const SizedBox(height: 6),
            _passwordField(),
            const SizedBox(height: 6),
            _forgotBtn(),
            const SizedBox(height: 18),
            _loginBtn(),
            const SizedBox(height: 20),
            _dividerRow(),
            const SizedBox(height: 16),
            _registerBtn(),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              'Welcome Back',
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
            'Enter your credentials to continue',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: _C.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

  Widget _emailField() => TextField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    autocorrect: false,
    style: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _C.textPrimary,
    ),
    decoration: _inputDecor(
      hint: 'you@example.com',
      icon: Icons.email_outlined,
    ),
  );

  Widget _passwordField() => Obx(
    () => TextField(
      controller: passwordController,
      obscureText: controller.isPasswordHidden.value,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) =>
          controller.handleLogin(emailController.text, passwordController.text),
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _C.textPrimary,
      ),
      decoration: _inputDecor(
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            controller.isPasswordHidden.value
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _C.textSub,
            size: 20,
          ),
          onPressed: controller.togglePassword,
          splashRadius: 20,
        ),
      ),
    ),
  );

  Widget _forgotBtn() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Get.to(() => const ForgetPassword()),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Forgot Password?',
        style: GoogleFonts.nunito(
          color: _C.indigo,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  Widget _loginBtn() => Obx(
    () => SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.handleLogin(
                emailController.text,
                passwordController.text,
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.indigo.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Login',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    ),
  );

  Widget _dividerRow() => Row(
    children: [
      Expanded(child: Divider(color: _C.divider, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'New here?',
          style: GoogleFonts.nunito(
            color: _C.textSub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(child: Divider(color: _C.divider, thickness: 1)),
    ],
  );

  Widget _registerBtn() => SizedBox(
    width: double.infinity,
    height: 50,
    child: OutlinedButton(
      onPressed: () => Get.to(() => const RegisterScreen()),
      style: OutlinedButton.styleFrom(
        foregroundColor: _C.indigo,
        side: BorderSide(color: _C.indigo.withValues(alpha: 0.5), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        'Create an Account',
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _C.indigo,
        ),
      ),
    ),
  );

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
