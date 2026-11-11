import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_meta.dart';
import '../../core/utils/format_utils.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/status_badge.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  const OpportunityDetailsScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  State<OpportunityDetailsScreen> createState() => _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final OpportunityProvider provider = context.read<OpportunityProvider>();
      if (!provider.loading && provider.all.isEmpty) provider.load();
      final String? uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) provider.loadMyApplications(uid);
    });
  }

  Opportunity? get _opportunity {
    final List<Opportunity> all = context.read<OpportunityProvider>().all;
    for (final Opportunity opportunity in all) {
      if (opportunity.id == widget.opportunityId) return opportunity;
    }
    return null;
  }

  Future<void> _apply(Opportunity opportunity) async {
    final AuthProvider auth = context.read<AuthProvider>();
    setState(() => _actionBusy = true);
    final bool ok = await context.read<OpportunityProvider>().apply(
          opportunity,
          volunteerId: auth.user!.uid,
          volunteerName: auth.volunteerProfile?.name ?? auth.user!.displayName ?? 'Volunteer',
        );
    if (!mounted) return;
    setState(() => _actionBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Application sent to ${opportunity.ngoName}!' : 'Could not apply. Try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancel(Application application) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cancel application?'),
            content: const Text('You can re-apply later if the role is still open.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep')),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancel')),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    final bool ok = await context.read<OpportunityProvider>().cancelApplication(application);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Application cancelled.' : 'Could not cancel right now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OpportunityProvider provider = context.watch<OpportunityProvider>();
    final Opportunity? opportunity = _opportunity;

    if (opportunity == null) {
      return Scaffold(
        body: Center(
          child: provider.loading
              ? const CircularProgressIndicator()
              : const Text('Opportunity not found.'),
        ),
      );
    }

    final Application? application = provider.applicationFor(opportunity.id);
    final String category = opportunity.category;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: const _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: CategoryMeta.gradientFor(category)),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0.8, -0.2),
                      child: Icon(
                        CategoryMeta.iconFor(category),
                        color: Colors.white.withValues(alpha: 0.25),
                        size: 140,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            opportunity.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white, size: 17),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${opportunity.ngoName} · ${opportunity.location}',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        InfoTile(
                          icon: Icons.calendar_month_rounded,
                          label: 'Date',
                          value: formatFullDate(opportunity.date),
                        ),
                        const Divider(height: 24),
                        InfoTile(
                          icon: Icons.schedule_rounded,
                          label: 'Time',
                          value: '${opportunity.startTime} – ${opportunity.endTime}',
                        ),
                        const Divider(height: 24),
                        InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: opportunity.location,
                        ),
                        const Divider(height: 24),
                        InfoTile(
                          icon: Icons.group_rounded,
                          label: 'Volunteers needed',
                          value: '${opportunity.currentVolunteers} of ${opportunity.requiredVolunteers} spots filled',
                          iconColor: opportunity.isFilled ? AppColors.error : AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('About this cause', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    opportunity.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (opportunity.requiredSkills.isNotEmpty) ...[
                    Text('Skills', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: opportunity.requiredSkills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _ApplicationStateCard(application: application),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        busy: _actionBusy,
        opportunity: opportunity,
        application: application,
        onApply: () => _apply(opportunity),
        onCancel: application == null ? null : () => _cancel(application),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _ApplicationStateCard extends StatelessWidget {
  const _ApplicationStateCard({required this.application});

  final Application? application;

  @override
  Widget build(BuildContext context) {
    final Application? maybeApplication = application;
    if (maybeApplication == null) return const SizedBox.shrink();
    final Application app = maybeApplication;
    final String status = app.status.toLowerCase();
    final bool pending = status == 'pending';
    final bool approved = status == 'approved';

    final IconData icon = pending ? Icons.hourglass_top_rounded : Icons.verified_rounded;
    final String title = pending
        ? 'Application sent'
        : approved
            ? 'You are on the team!'
            : 'Application ${app.status}';
    final String message = pending
        ? 'The NGO will review your application and respond shortly.'
        : approved
            ? 'The NGO approved your application. Show up and make a difference!'
            : 'Your application status is ${app.status}.';

    return RoundedCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (pending ? AppColors.warning : approved ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: pending ? AppColors.warning : approved ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
                const SizedBox(height: 10),
                StatusBadge(status: app.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.busy,
    required this.opportunity,
    required this.application,
    required this.onApply,
    required this.onCancel,
  });

  final bool busy;
  final Opportunity opportunity;
  final Application? application;
  final VoidCallback onApply;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final bool filled = opportunity.isFilled || !opportunity.isOpen;
    final Application? app = application;
    final bool applied = app != null && (app.status.toLowerCase() == 'pending' || app.status.toLowerCase() == 'approved');
    final bool showStatus = app != null && !app.isPending;

    String buttonLabel;
    if (app != null && app.isPending) {
      buttonLabel = 'Application pending';
    } else if (app != null && app.isApproved) {
      buttonLabel = 'Apply complete';
    } else if (filled) {
      buttonLabel = 'Filled';
    } else {
      buttonLabel = 'Apply now';
    }
    if (busy) buttonLabel = 'Working…';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (app != null && showStatus)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      app.isApproved ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: app.isApproved ? AppColors.success : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      app.isApproved ? 'Approved for this cause' : 'Status: ${app.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            GradientButton(
              label: buttonLabel,
              icon: app == null && !filled ? Icons.volunteer_activism_rounded : null,
              onPressed: busy || applied || filled ? null : onApply,
            ),
            if (app != null && !app.isApproved)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GhostButton(label: 'Cancel application', onPressed: busy ? null : onCancel!),
              ),
          ],
        ),
      ),
    );
  }
}