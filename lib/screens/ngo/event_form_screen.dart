import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/format_utils.dart';
import '../../models/volunteer_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/gradient_button.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.existing});

  final VolunteerEvent? existing;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location ?? '');
  late DateTime _date = widget.existing?.date ?? DateTime.now().add(const Duration(days: 14));
  late String _startTime = widget.existing?.startTime ?? '09:00';
  late String _endTime = widget.existing?.endTime ?? '14:00';
  late int _maxVolunteers = widget.existing?.maxVolunteers ?? 20;
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

  Future<void> _pickTime({required bool start}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(start ? _startTime : _endTime),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = _formatTime(picked);
        } else {
          _endTime = _formatTime(picked);
        }
      });
    }
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

    final AuthProvider auth = context.read<AuthProvider>();
    final EventProvider provider = context.read<EventProvider>();
    final String ngoId = auth.user?.uid ?? '';
    final VolunteerEvent? previous = widget.existing;

    final VolunteerEvent updated = VolunteerEvent(
      id: previous?.id ?? 'ev-${DateTime.now().millisecondsSinceEpoch}',
      ngoId: previous?.ngoId ?? ngoId,
      ngoName: previous?.ngoName ?? auth.ngoProfile?.name ?? auth.user?.displayName ?? 'Organization',
      title: title,
      description: description,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      location: _location.text.trim().isEmpty ? 'TBD' : _location.text.trim(),
      maxVolunteers: _maxVolunteers,
      registeredVolunteers: previous?.registeredVolunteers ?? 0,
      image: previous?.image,
      status: previous?.status ?? 'upcoming',
      createdAt: previous?.createdAt,
    );

    setState(() => _saving = true);
    final bool ok = await provider.saveEvent(updated, ngoId);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Event saved!' : 'Could not save. Try again.'),
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
        title: Text(isEditing ? 'Edit event' : 'New event'),
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
                  const Icon(Icons.event_rounded, color: Colors.white, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    isEditing ? 'Update the event details' : 'Plan a volunteer event',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Event details', style: Theme.of(context).textTheme.titleMedium),
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
            Text('Schedule & location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _FieldButton(
              icon: Icons.calendar_today_rounded,
              label: formatDate(_date, pattern: 'EEE, d MMM y'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FieldButton(
                    icon: Icons.schedule_rounded,
                    label: _startTime,
                    onTap: () => _pickTime(start: true),
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
                    onTap: () => _pickTime(start: false),
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
            Text('Capacity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filled(
                  onPressed: _maxVolunteers > 1 ? () => setState(() => _maxVolunteers -= 1) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_maxVolunteers',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => _maxVolunteers += 1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: _saving ? 'Saving…' : isEditing ? 'Save changes' : 'Create event',
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