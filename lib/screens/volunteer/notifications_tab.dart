import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/shimmer_placeholder.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  (IconData, Color) _typeMeta(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return (Icons.volunteer_activism_rounded, AppColors.primary);
      case 'event':
        return (Icons.event_available_rounded, AppColors.accent);
      case 'application':
        return (Icons.send_rounded, AppColors.warning);
      case 'hours':
        return (Icons.timer_rounded, AppColors.success);
      default:
        return (Icons.notifications_rounded, AppColors.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationProvider provider = context.watch<NotificationProvider>();
    final AuthProvider auth = context.watch<AuthProvider>();
    final List<AppNotification> items = provider.items;
    final bool hasUnread = provider.unreadCount > 0;

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
                      Text('Alerts', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        provider.unreadCount == 0 ? 'You are all caught up' : '${provider.unreadCount} unread',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: hasUnread && auth.user != null ? () => provider.markAllRead(auth.user!.uid) : null,
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.poppins(
                      color: hasUnread ? AppColors.primary : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final String? uid = auth.user?.uid;
                if (uid != null) await provider.load(uid);
              },
              child: provider.loading && items.isEmpty
                  ? const ListShimmer(count: 5)
                  : items.isEmpty
                      ? const EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'Nothing here yet',
                          subtitle: 'Updates about your applications and events will appear here.',
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final AppNotification notification = items[index];
                            final (IconData, Color) meta = _typeMeta(notification.type);
                            return _NotificationTile(
                              notification: notification,
                              icon: meta.$1,
                              color: meta.$2,
                              onTap: () async {
                                if (!notification.isRead) {
                                  await provider.markRead(notification.id);
                                }
                              },
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RoundedCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: notification.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}