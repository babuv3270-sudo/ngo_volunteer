import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../models/ngo_profile.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/rounded_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  bool get _isNgo => widget.role == UserRole.ngo;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool success;
    if (_isNgo) {
      success = await auth.signUpNgo(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        password: _passwordController.text,
        ngoDetails: NgoProfile(
          uid: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        ),
      );
    } else {
      success = await auth.signUpVolunteer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    if (success) {
      final String destination = auth.isVolunteer ? AppRoutes.volunteerHome : AppRoutes.ngoHome;
      Navigator.of(context).pushNamedAndRemoveUntil(destination, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')));
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_isNgo ? Icons.account_balance_rounded : Icons.volunteer_activism_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _isNgo ? 'NGO account' : 'Volunteer account',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isNgo ? 'Create your organization' : 'Create your account',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _isNgo
                      ? 'Tell us about your organization to start.'
                      : 'A few details and you are ready to volunteer.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
                ),
                const SizedBox(height: 32),
                RoundedCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.name(v, minLength: _isNgo ? 3 : 2),
                        decoration: InputDecoration(
                          labelText: _isNgo ? 'Organization name' : 'Full name',
                          hintText: _isNgo ? 'e.g. Green Earth Foundation' : 'e.g. Aarav Shah',
                          prefixIcon: Icon(_isNgo ? Icons.business_outlined : Icons.person_outline_rounded),
                        ),
                      ),
                      if (_isNgo) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'What does your NGO do?',
                            prefixIcon: Icon(Icons.notes_rounded),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
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
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          hintText: '+91 98765 43210',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: _isNgo ? 'Create organization' : 'Create account',
                        icon: Icons.how_to_reg_rounded,
                        loading: auth.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}