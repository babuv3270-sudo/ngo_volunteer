import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/demo_seed_service.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/rounded_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _demoLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      _goHome(auth.user?.role);
    } else {
      _showError(auth.errorMessage);
    }
  }

  void _goHome(UserRole? role) {
    final String destination = role == UserRole.volunteer ? AppRoutes.volunteerHome : AppRoutes.ngoHome;
    Navigator.of(context).pushNamedAndRemoveUntil(destination, (_) => false);
  }

  void _showError(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _fillDemo() {
    final AuthProvider auth = context.read<AuthProvider>();
    if (!auth.isDemoMode) {
      _prepareDemo(() {
        _setDemoCredentials('demo@ngo.app');
      });
      return;
    }
    _setDemoCredentials('demo@ngo.app');
  }

  void _fillNgoDemo() {
    final AuthProvider auth = context.read<AuthProvider>();
    if (!auth.isDemoMode) {
      _prepareDemo(() {
        _setDemoCredentials('demo-ngo@ngo.app');
      });
      return;
    }
    _setDemoCredentials('demo-ngo@ngo.app');
  }

  Future<void> _prepareDemo(VoidCallback onReady) async {
    if (_demoLoading) return;
    setState(() => _demoLoading = true);
    try {
      await DemoSeedService().ensureSeeded();
      if (!mounted) return;
      onReady();
    } catch (_) {
      if (mounted) {
        _showError('Could not prepare demo data. Check your Firebase setup.');
      }
    } finally {
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  void _setDemoCredentials(String email) {
    _emailController.text = email;
    _passwordController.text = 'demo1234';
    setState(() {});
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Welcome back',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue your volunteering journey.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
                ),
                const SizedBox(height: 32),
                RoundedCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: Validators.password,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'At least 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GradientButton(
                        label: 'Sign in',
                        icon: Icons.login_rounded,
                        loading: auth.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                if (auth.isDemoMode) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Try a demo account',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Text(
                    'Try a demo account (creates sample data on first use)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 10),
                RoundedCard(
                  gradient: AppGradients.subtleCard,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: _demoLoading ? null : _fillDemo,
                  child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Try the demo volunteer account', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                'demo@ngo.app · demo1234',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (_demoLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedCard(
                    gradient: AppGradients.subtleCard,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    onTap: _demoLoading ? null : _fillNgoDemo,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.apartment_rounded, color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Try the demo NGO account', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                'demo-ngo@ngo.app · demo1234',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (_demoLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 20),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.roleSelection),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                          children: [
                            const TextSpan(text: 'New here?  '),
                            TextSpan(
                              text: 'Create an account',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}