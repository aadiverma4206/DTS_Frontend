import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/services/api_service/api_service.dart';
import '../../admin/admin_home.dart';
import '../../inspector/inspector_home.dart';
import '../../retailer/retailer_home.dart';
import '../../wholesaler/wholesaler_home.dart';
import 'auth_storage.dart';
import '../detail_registration_form/retailer_form.dart';
import '../detail_registration_form/wholesaler_form.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _scaleCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _shimmerAnim;

  static const _bg = Color(0xFFF0F4F8);
  static const _surface = Color(0xFFFFFFFF);
  static const _indigo = Color(0xFF4338CA);
  static const _indigoSoft = Color(0xFFEEF2FF);
  static const _purple = Color(0xFF7C3AED);
  static const _purpleSoft = Color(0xFFF3E8FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSub = Color(0xFF64748B);
  static const _divider = Color(0xFFE2E8F0);
  static const _green = Color(0xFF16A34A);
  static const _greenSoft = Color(0xFFDCFCE7);
  static const _blue = Color(0xFF0369A1);
  static const _blueSoft = Color(0xFFE0F2FE);
  static const _teal = Color(0xFF0F766E);
  static const _tealSoft = Color(0xFFCCFBF1);
  static const _rose = Color(0xFFBE123C);
  static const _roseSoft = Color(0xFFFFE4E6);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _textFadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _shimmerAnim = CurvedAnimation(
      parent: _shimmerCtrl,
      curve: Curves.easeInOut,
    );

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _slideCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 2400), _checkAuth);
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    final token = await AuthStorage.getToken();
    final role = await AuthStorage.getRole();
    final profileCompleted = await AuthStorage.isProfileCompleted();

    if (token == null || token.isEmpty || role == null) {
      Get.offAll(() => const LoginScreen());
      return;
    }
    ApiService.setToken(token);
    switch (role) {
      case 'wholesaler':
        Get.offAll(
          () => profileCompleted
              ? const WholesalerHome()
              : const WholesalerForm(),
        );
        break;
      case 'retailer':
        Get.offAll(
          () => profileCompleted ? const RetailerHome() : const RetailerForm(),
        );
        break;
      case 'admin':
        Get.offAll(() => const AdminHome());
        break;
      case 'inspector':
        Get.offAll(() => const InspectorHome());
        break;
      default:
        Get.offAll(() => const LoginScreen());
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _slideCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final logoSize = isDesktop
        ? 110.0
        : isTablet
        ? 92.0
        : 76.0;
    final iconSize = isDesktop
        ? 56.0
        : isTablet
        ? 46.0
        : 38.0;
    final titleSize = isDesktop
        ? 32.0
        : isTablet
        ? 26.0
        : 21.0;
    final subtitleSize = isDesktop
        ? 14.0
        : isTablet
        ? 13.0
        : 11.5;
    final taglineSize = isDesktop
        ? 13.0
        : isTablet
        ? 12.0
        : 11.0;

    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            _bgDecor(size, isTablet),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? 500
                        : isTablet
                        ? 420
                        : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? 0
                          : isTablet
                          ? 0
                          : 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: _logoCard(logoSize, iconSize),
                        ),
                        SizedBox(
                          height: isDesktop
                              ? 32
                              : isTablet
                              ? 26
                              : 20,
                        ),
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _textFadeAnim,
                            child: _titleBlock(titleSize, subtitleSize),
                          ),
                        ),
                        SizedBox(
                          height: isDesktop
                              ? 40
                              : isTablet
                              ? 32
                              : 26,
                        ),
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _textFadeAnim,
                            child: _roleCards(isTablet),
                          ),
                        ),
                        SizedBox(
                          height: isDesktop
                              ? 56
                              : isTablet
                              ? 44
                              : 36,
                        ),
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _textFadeAnim,
                            child: _loaderCard(taglineSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: isTablet ? 24 : 16,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFadeAnim,
                child: Text(
                  'Drug Tracking Management System © 2026',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: _textSub.withValues(alpha: 0.55),
                    fontSize: isTablet ? 12 : 11,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bgDecor(Size size, bool isTablet) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: isTablet ? 280 : 200,
            height: isTablet ? 280 : 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -50,
          child: Container(
            width: isTablet ? 260 : 180,
            height: isTablet ? 260 : 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _purple.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.4,
          right: -size.width * 0.25,
          child: Container(
            width: isTablet ? 180 : 120,
            height: isTablet ? 180 : 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoCard(double logoSize, double iconSize) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, child) {
        return Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(logoSize * 0.28),
            border: Border.all(
              color: _indigo.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _indigo.withValues(
                  alpha: 0.13 + (_shimmerAnim.value * 0.07),
                ),
                blurRadius: 24 + (_shimmerAnim.value * 8),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: iconSize + 16,
          height: iconSize + 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular((iconSize + 16) * 0.3),
          ),
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: iconSize * 0.78,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _titleBlock(double titleSize, double subtitleSize) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Drug ',
                style: GoogleFonts.nunito(
                  color: _textPrimary,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  height: 1.15,
                ),
              ),
              TextSpan(
                text: 'Tracking',
                style: GoogleFonts.nunito(
                  color: _indigo,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Management System',
          style: GoogleFonts.nunito(
            color: _textSub,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 44,
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

  Widget _roleCards(bool isTablet) {
    final roles = [
      (Icons.factory_rounded, 'Manufacturer', _blue, _blueSoft),
      (Icons.local_shipping_rounded, 'Wholesaler', _teal, _tealSoft),
      (Icons.store_rounded, 'Retailer', _rose, _roseSoft),
      (Icons.search_rounded, 'Inspector', _green, _greenSoft),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: roles.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: r.$3.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: r.$3.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: r.$4,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(r.$1, size: 13, color: r.$3),
              ),
              const SizedBox(width: 7),
              Text(
                r.$2,
                style: GoogleFonts.nunito(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _loaderCard(double taglineSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
        boxShadow: [
          BoxShadow(
            color: _indigo.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(color: _indigo, strokeWidth: 2.2),
          ),
          const SizedBox(width: 12),
          Text(
            'Initializing secure session...',
            style: GoogleFonts.nunito(
              color: _textSub,
              fontSize: taglineSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
