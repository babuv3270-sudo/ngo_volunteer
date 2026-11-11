import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/rounded_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool success = await auth.sendPasswordReset(_emailController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Could not send reset link')));
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Reset password',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _sent ? 'Check your inbox for the reset link.' : "Enter your email and we'll send you a reset link.",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: AppDurations.normal,
                child: _sent
                    ? RoundedCard(
                        gradient: AppGradients.success,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Link sent to ${_emailController.text.trim()}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Text(
                                      'Back to sign in',
                                      style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RoundedCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: Validators.email,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                label: 'Send reset link',
                                icon: Icons.send_rounded,
                                loading: auth.isLoading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}