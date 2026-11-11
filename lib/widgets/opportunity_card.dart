import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/category_meta.dart';
import '../models/opportunity.dart';
import '../widgets/status_badge.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.applied = false,
    this.onTap,
    this.compact = false,
  });

  final Opportunity opportunity;
  final bool applied;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: compact ? 92 : 108,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: CategoryMeta.gradientFor(opportunity.category),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Icon(CategoryMeta.iconFor(opportunity.category), color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          opportunity.category,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: StatusBadge(status: opportunity.isOpen ? 'open' : 'closed', outlined: true),
                  ),
                  if (applied)
                    const Align(
                      alignment: Alignment.topLeft,
                      child: StatusBadge(status: 'approved', outlined: true),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    opportunity.ngoName,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaIcon(
                          icon: Icons.calendar_today_rounded,
                          label: '${_dayLabel(opportunity.date)} · ${opportunity.startTime}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaIcon(
                          icon: Icons.location_on_outlined,
                          label: opportunity.location,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: opportunity.fillRatio,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceMuted,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${opportunity.currentVolunteers}/${opportunity.requiredVolunteers}',
                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(date.year, date.month, date.day);
    final int diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${day.day} ${_months[day.month - 1]}';
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}