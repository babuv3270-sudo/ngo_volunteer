import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../models/app_user.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_scaffold.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  void _continue() {
    if (_selected == null) return;
    Navigator.of(context).pushNamed(AppRoutes.register, arguments: _selected);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'How will you help?',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the account type that fits you best.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _RoleCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Volunteer',
                      subtitle: 'Discover causes, join events, and track the hours you give.',
                      accent: AppGradients.success,
                      selected: _selected == UserRole.volunteer,
                      onTap: () => setState(() => _selected = UserRole.volunteer),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      icon: Icons.account_balance_rounded,
                      title: 'NGO / Organization',
                      subtitle: 'Create opportunities, manage events, and welcome volunteers.',
                      accent: AppGradients.info,
                      selected: _selected == UserRole.ngo,
                      onTap: () => setState(() => _selected = UserRole.ngo),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: Text(
                        'Already have an account?  Sign in',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: InkWell(
                    onTap: _continue,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Center(
                      child: Text(
                        _selected == null ? 'Continue' : 'Continue as ${_label(_selected!)}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(UserRole role) => role == UserRole.volunteer ? 'Volunteer' : 'NGO';
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.25),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(gradient: accent, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: AppDurations.normal,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}