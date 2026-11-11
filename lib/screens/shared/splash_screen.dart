import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_gradients.dart';
import '../../firebase/firebase_config.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _pulse;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _next();
  }

  Future<void> _next() async {
    final AuthProvider auth = context.read<AuthProvider>();
    await Future.delayed(const Duration(milliseconds: 2000));
    await auth.initialization;
    if (!mounted) return;
    final UserRole? role = auth.user?.role;
    final String destination = role == null
        ? AppRoutes.onboarding
        : (role == UserRole.volunteer ? AppRoutes.volunteerHome : AppRoutes.ngoHome);
    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: AppGradients.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.08).animate(_pulse),
              child: FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(_fadeIn),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, size: 64, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.appName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),
            if (FirebaseConfig.isConfigured == false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Demo mode — Firebase not connected',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const Spacer(flex: 3),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}