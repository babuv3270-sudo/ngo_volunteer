import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/category_meta.dart';
import '../../models/opportunity.dart';
import '../../providers/opportunity_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/shimmer_placeholder.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  void _showSortSheet(BuildContext context) {
    final OpportunityProvider provider = context.read<OpportunityProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort by', style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                ...AppSortOptions.all.map((option) {
                  final bool active = provider.sort == option;
                  return InkWell(
                    onTap: () {
                      provider.setSort(option);
                      Navigator.of(sheetContext).pop();
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            active
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: active ? AppColors.primary : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option,
                            style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                                  color: active ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final OpportunityProvider provider = context.watch<OpportunityProvider>();
    final List<Opportunity> opportunities = provider.display;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  '${provider.all.length} causes waiting for you',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: provider.setQuery,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search causes, NGOs, skills…',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                          suffixIcon: provider.hasActiveFilters
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                                  onPressed: provider.clearFilters,
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showSortSheet(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryCompact,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: provider.category == null,
                        onTap: () => provider.setCategory(null),
                      ),
                      ...AppCategories.all.map((category) {
                        return _CategoryChip(
                          label: category,
                          selected: provider.category == category,
                          onTap: () => provider.setCategory(category),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.load,
              child: provider.loading
                  ? const ListShimmer(count: 4)
                  : opportunities.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches',
                          subtitle: 'Try a different keyword or category.',
                          actionLabel: 'Clear filters',
                          onAction: provider.clearFilters,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: opportunities.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final Opportunity opportunity = opportunities[index];
                            return OpportunityCard(
                              opportunity: opportunity,
                              applied: provider.hasApplied(opportunity.id),
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.opportunityDetails,
                                arguments: opportunity.id,
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                selected ? CategoryMeta.iconFor(label) : Icons.folder_outlined,
                color: selected ? Colors.white : AppColors.textSecondary,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}