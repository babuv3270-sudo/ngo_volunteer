import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/application.dart';
import '../../providers/opportunity_provider.dart';
import '../../widgets/avatar_pill.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/shimmer_placeholder.dart';
import '../../widgets/status_badge.dart';

class OpportunityApplicantsScreen extends StatefulWidget {
  const OpportunityApplicantsScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  State<OpportunityApplicantsScreen> createState() => _OpportunityApplicantsScreenState();
}

class _OpportunityApplicantsScreenState extends State<OpportunityApplicantsScreen> {
  String _busyId = '';

  String? _opportunityTitle(BuildContext context) {
    final OpportunityProvider provider = context.read<OpportunityProvider>();
    for (final opportunity in provider.ngoOpportunities) {
      if (opportunity.id == widget.opportunityId) return opportunity.title;
    }
    return null;
  }

  Future<void> _decide(Application application, String status) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(status == 'approved' ? 'Approve application?' : 'Reject application?'),
            content: Text(
              status == 'approved'
                  ? '${application.volunteerName} will be notified that they have been selected.'
                  : '${application.volunteerName} will be notified that they were not selected.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(status == 'approved' ? 'Approve' : 'Reject'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _busyId = application.id);
    final bool ok = await context.read<OpportunityProvider>().updateApplicationStatus(application, status);
    if (!mounted) return;
    setState(() => _busyId = '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Decision saved.' : 'Could not save. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OpportunityProvider provider = context.watch<OpportunityProvider>();
    final List<Application> applications = provider.applicationsForOpportunity(widget.opportunityId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          if (_opportunityTitle(context) != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _opportunityTitle(context)!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  Text(
                    '${applications.length} applied',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          Expanded(
            child: provider.ngoLoading
                ? const ListShimmer(count: 4)
                : applications.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'No applicants yet',
                        subtitle: 'When volunteers apply, they will show up here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: applications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final Application application = applications[index];
                          final bool busy = _busyId == application.id;
                          return RoundedCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AvatarPill(name: application.volunteerName, size: 44),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            application.volunteerName,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Applied for "${application.opportunityTitle}"',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: application.status),
                                  ],
                                ),
                                if (application.isPending) ...[
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: OutlinedButton.icon(
                                            onPressed: busy ? null : () => _decide(application, 'rejected'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              side: const BorderSide(color: AppColors.error),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppRadius.md),
                                              ),
                                            ),
                                            icon: const Icon(Icons.close_rounded, size: 18),
                                            label: const Text('Decline'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: GradientButton(
                                            label: busy ? 'Saving…' : 'Approve',
                                            height: 44,
                                            radius: AppRadius.md,
                                            disabled: busy,
                                            onPressed: busy
                                                ? null
                                                : () => _decide(application, 'approved'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}