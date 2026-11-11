import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../volunteer/notifications_tab.dart';
import 'dashboard_tab.dart';
import 'events_tab.dart';
import 'opportunities_tab.dart';
import 'profile_tab.dart';

class NgoShell extends StatefulWidget {
  const NgoShell({super.key});

  @override
  State<NgoShell> createState() => _NgoShellState();
}

class _NgoShellState extends State<NgoShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final AuthProvider auth = context.read<AuthProvider>();
    final String? uid = auth.user?.uid;
    if (uid == null) return;

    context.read<OpportunityProvider>().loadNgo(uid);
    context.read<EventProvider>().loadNgo(uid);
    context.read<NotificationProvider>().load(uid);
  }

  void _onTabChanged(int index) {
    setState(() => _index = index);
    if (index == 3) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    if (!auth.isSignedIn || auth.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final int badgeCount = notificationProvider.unreadCount;

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              DashboardTab(onNavigateToTab: _onTabChanged),
              const OpportunitiesTab(),
              const EventsTab(),
              const NotificationsTab(),
              const ProfileTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onTabChanged,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.volunteer_activism_outlined),
                selectedIcon: Icon(Icons.volunteer_activism_rounded),
                label: 'Causes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event_rounded),
                label: 'Events',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text('$badgeCount'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text('$badgeCount'),
                  child: const Icon(Icons.notifications_rounded),
                ),
                label: 'Alerts',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}