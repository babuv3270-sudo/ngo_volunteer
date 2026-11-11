import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/shimmer_placeholder.dart';
import '../../widgets/status_badge.dart';

class OpportunitiesTab extends StatelessWidget {
  const OpportunitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final OpportunityProvider provider = context.watch<OpportunityProvider>();
    final String ngoId = context.read<AuthProvider>().user?.uid ?? '';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Causes', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.ngoOpportunities.length} opportunities',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: 'ngo-opp-fab',
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.ngoOpportunityForm,
                    arguments: null,
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  tooltip: 'New cause',
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadNgo(ngoId),
              child: provider.ngoLoading && provider.ngoOpportunities.isEmpty
                  ? const ListShimmer(count: 4)
                  : provider.ngoOpportunities.isEmpty
                      ? EmptyState(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'No causes yet',
                          subtitle: 'Create your first opportunity to start receiving volunteer applications.',
                          actionLabel: 'New cause',
                          onAction: () => Navigator.of(context).pushNamed(
                            AppRoutes.ngoOpportunityForm,
                            arguments: null,
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                          itemCount: provider.ngoOpportunities.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final Opportunity opportunity = provider.ngoOpportunities[index];
                            return _OpportunityRow(
                              opportunity: opportunity,
                              pendingCount: provider.pendingCountFor(opportunity.id),
                              applicantCount: provider.applicationsForOpportunity(opportunity.id).length,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.ngoApplicants,
                                arguments: opportunity.id,
                              ),
                              onEdit: () => Navigator.of(context).pushNamed(
                                AppRoutes.ngoOpportunityForm,
                                arguments: opportunity,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityRow extends StatelessWidget {
  const _OpportunityRow({
    required this.opportunity,
    required this.pendingCount,
    required this.applicantCount,
    required this.onTap,
    required this.onEdit,
  });

  final Opportunity opportunity;
  final int pendingCount;
  final int applicantCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final double ratio = opportunity.fillRatio;

    return RoundedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${opportunity.category} · ${formatDate(opportunity.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: opportunity.status),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.people_outline_rounded, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$applicantCount applied · $pendingCount pending',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${opportunity.currentVolunteers}/${opportunity.requiredVolunteers} filled',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          if (pendingCount > 0)
            Text(
              '$pendingCount volunteer${pendingCount == 1 ? '' : 's'} waiting for review',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning, fontSize: 12),
            ),
        ],
      ),
    );
  }
}