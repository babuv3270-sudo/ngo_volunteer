import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/format_utils.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../widgets/chip_chooser.dart';
import '../../widgets/gradient_button.dart';

class OpportunityFormScreen extends StatefulWidget {
  const OpportunityFormScreen({super.key, this.existing});

  final Opportunity? existing;

  @override
  State<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends State<OpportunityFormScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location ?? '');
  late DateTime _date = widget.existing?.date ?? DateTime.now().add(const Duration(days: 7));
  late String _startTime = widget.existing?.startTime ?? '09:00';
  late String _endTime = widget.existing?.endTime ?? '13:00';
  late String? _category = widget.existing?.category;
  late List<String> _skills = [...?widget.existing?.requiredSkills];
  late int _requiredVolunteers = widget.existing?.requiredVolunteers ?? 10;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_startTime),
    );
    if (picked != null) setState(() => _startTime = _formatTime(picked));
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_endTime),
    );
    if (picked != null) setState(() => _endTime = _formatTime(picked));
  }

  TimeOfDay _parseTime(String value) {
    final List<String> parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final String title = _title.text.trim();
    final String description = _description.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and description.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final AuthProvider auth = context.read<AuthProvider>();
    final OpportunityProvider provider = context.read<OpportunityProvider>();
    final String ngoId = auth.user?.uid ?? '';
    final Opportunity? previous = widget.existing;

    final Opportunity updated = Opportunity(
      id: previous?.id ?? 'op-${DateTime.now().millisecondsSinceEpoch}',
      ngoId: previous?.ngoId ?? ngoId,
      ngoName: previous?.ngoName ?? auth.ngoProfile?.name ?? auth.user?.displayName ?? 'Organization',
      title: title,
      description: description,
      category: _category!,
      requiredSkills: _skills,
      location: _location.text.trim().isEmpty ? 'TBD' : _location.text.trim(),
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      requiredVolunteers: _requiredVolunteers,
      currentVolunteers: previous?.currentVolunteers ?? 0,
      image: previous?.image,
      status: previous?.status ?? 'open',
      createdAt: previous?.createdAt,
    );

    setState(() => _saving = true);
    final bool ok = await provider.saveOpportunity(updated, ngoId);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Cause saved!' : 'Could not save. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit cause' : 'New cause'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppGradients.primaryBoxDecoration(radius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    isEditing ? 'Update the opportunity details' : 'Describe the volunteering opportunity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Basic details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title').applyDefaults(Theme.of(context).inputDecorationTheme),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description').applyDefaults(Theme.of(context).inputDecorationTheme),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ChipChooser(
              options: AppCategories.all,
              selected: (option) => option == _category ? option : null,
              onChanged: (option) => setState(() => _category = option == _category ? null : option),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Skills volunteers should have', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppSkills.all.map((skill) {
                final bool active = _skills.contains(skill);
                return GestureDetector(
                  onTap: () => setState(() {
                    _skills = active ? _skills.where((s) => s != skill).toList() : [..._skills, skill];
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: active ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Schedule & location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
Row(
                children: [
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.calendar_today_rounded,
                      label: formatDate(_date, pattern: 'EEE, d MMM y'),
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.schedule_rounded,
                      label: _startTime,
                      onTap: _pickStartTime,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.schedule_rounded,
                      label: _endTime,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location').applyDefaults(Theme.of(context).inputDecorationTheme),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Volunteers needed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filled(
                  onPressed: _requiredVolunteers > 1
                      ? () => setState(() => _requiredVolunteers -= 1)
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_requiredVolunteers',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _requiredVolunteers += 1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: _saving ? 'Saving…' : isEditing ? 'Save changes' : 'Create cause',
              icon: _saving ? null : Icons.check_rounded,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}