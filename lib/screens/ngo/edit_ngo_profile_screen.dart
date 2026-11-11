import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/ngo_profile.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/gradient_button.dart';

class EditNgoProfileScreen extends StatefulWidget {
  const EditNgoProfileScreen({super.key});

  @override
  State<EditNgoProfileScreen> createState() => _EditNgoProfileScreenState();
}

class _EditNgoProfileScreenState extends State<EditNgoProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: _profile?.name ?? '');
  late final TextEditingController _phone = TextEditingController(text: _profile?.phone ?? '');
  late final TextEditingController _city = TextEditingController(text: _profile?.city ?? '');
  late final TextEditingController _address = TextEditingController(text: _profile?.address ?? '');
  late final TextEditingController _website = TextEditingController(text: _profile?.website ?? '');
  late final TextEditingController _description = TextEditingController(text: _profile?.description ?? '');
  bool _saving = false;

  NgoProfile? get _profile => context.read<AuthProvider>().ngoProfile;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    _website.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the organization name.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    final NgoProfile base =
        auth.ngoProfile ?? NgoProfile(uid: auth.user?.uid ?? '', name: name);

    setState(() => _saving = true);
    final bool ok = await auth.updateNgoProfile(base.copyWith(
      name: name,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      website: _website.text.trim().isEmpty ? null : _website.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
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
    final NgoProfile? profile = _profile;
    final String name = profile?.name.isNotEmpty == true ? profile!.name : 'Organization';

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
                child: AvatarPill(imageUrl: profile?.logo, name: name, size: 104),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Organization details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Organization name').applyDefaults(
                Theme.of(context).inputDecorationTheme,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'About (optional)').applyDefaults(
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City (optional)').applyDefaults(
                      Theme.of(context).inputDecorationTheme,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address (optional)').applyDefaults(
                      Theme.of(context).inputDecorationTheme,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _website,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Website (optional)').applyDefaults(
                Theme.of(context).inputDecorationTheme,
              ),
            ),
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
}