import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/chat/presentation/providers/chat_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUnread = ref.watch(chatUnreadTotalProvider);
    final hasChatActivity = ref.watch(chatHasActivityProvider);

    final destinationCount = 5;

    void goToIndex(int index) {
      if (index < 0 || index >= destinationCount) return;
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          // Ignore small/ambiguous swipes.
          if (velocity.abs() < 200) return;
          if (velocity < 0) {
            // Swiped left -> move to next page.
            goToIndex(navigationShell.currentIndex + 1);
          } else {
            // Swiped right -> move to previous page.
            goToIndex(navigationShell.currentIndex - 1);
          }
        },
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: goToIndex,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital_rounded),
            label: 'Utilities',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Bản đồ',
          ),
          NavigationDestination(
            icon: _ChatNavIcon(
              unreadCount: chatUnread,
              hasActivity: hasChatActivity,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: _ChatNavIcon(
              unreadCount: chatUnread,
              hasActivity: hasChatActivity,
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

class _ChatNavIcon extends StatelessWidget {
  const _ChatNavIcon({
    required this.unreadCount,
    required this.hasActivity,
    required this.child,
  });

  final int unreadCount;
  final bool hasActivity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadCount > 0 || hasActivity;
    return Badge(
      isLabelVisible: showBadge,
      label: unreadCount > 0
          ? Text(unreadCount > 99 ? '99+' : '$unreadCount')
          : null,
      child: child,
    );
  }
}
