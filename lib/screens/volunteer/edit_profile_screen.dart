import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: _profile?.name ?? '');
  late final TextEditingController _phone = TextEditingController(text: _profile?.phone ?? '');
  late final TextEditingController _location = TextEditingController(text: _profile?.location ?? '');

  late List<String> _skills = [...?_profile?.skills];
  late List<String> _interests = [...?_profile?.interests];
  bool _saving = false;

  AppUser? get _profile => context.read<AuthProvider>().volunteerProfile;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    final AppUser base = auth.volunteerProfile ?? AppUser(uid: '', name: name, email: '', role: UserRole.volunteer);

    setState(() => _saving = true);
    final bool ok = await auth.updateVolunteerProfile(base.copyWith(
      name: name,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      skills: _skills,
      interests: _interests,
    ));
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profile updated!' : 'Could not save. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser profile = _profile ?? const AppUser(uid: '', name: '', email: '', role: UserRole.volunteer);
    final String name = profile.name.isNotEmpty ? profile.name : 'Volunteer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.transparent,
                child: AvatarPill(imageUrl: profile.profileImage, name: name, size: 104),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Personal details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name').applyDefaults(
                Theme.of(context).inputDecorationTheme,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)').applyDefaults(
                Theme.of(context).inputDecorationTheme,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'City').applyDefaults(
                Theme.of(context).inputDecorationTheme,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _skillWrap(selected: _skills, onChange: (value) {
              setState(() => _skills = value);
            }),
            const SizedBox(height: AppSpacing.lg),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _skillWrap(selected: _interests, onChange: (value) {
              setState(() => _interests = value);
            }),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: _saving ? 'Saving…' : 'Save changes',
              icon: _saving ? null : Icons.check_rounded,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillWrap({required List<String> selected, required ValueChanged<List<String>> onChange}) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: AppSkills.all.map((skill) {
        final bool active = selected.contains(skill);
        return GestureDetector(
          onTap: () {
            onChange(active ? selected.where((s) => s != skill).toList() : [...selected, skill]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? AppColors.primary : AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active) ...[
                  const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                ],
                Text(
                  skill,
                  style: GoogleFonts.poppins(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}