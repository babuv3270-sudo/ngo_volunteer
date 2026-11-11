import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/opportunity_provider.dart';
import 'activities_tab.dart';
import 'dashboard_tab.dart';
import 'explore_tab.dart';
import 'notifications_tab.dart';
import 'profile_tab.dart';

class VolunteerShell extends StatefulWidget {
  const VolunteerShell({super.key});

  @override
  State<VolunteerShell> createState() => _VolunteerShellState();
}

class _VolunteerShellState extends State<VolunteerShell> {
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

    context.read<OpportunityProvider>().load();
    context.read<OpportunityProvider>().loadMyApplications(uid);
    context.read<EventProvider>().load();
    context.read<EventProvider>().loadMyRegistrations(uid);
    context.read<NotificationProvider>().load(uid);
  }

  void _onTabChanged(int index) {
    setState(() => _index = index);
    if (index == 1 || index == 2) _loadData();
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
              const ExploreTab(),
              const ActivitiesTab(),
              const NotificationsTab(),
              const ProfileTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onTabChanged,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(Icons.event_available_rounded),
                label: 'Activities',
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