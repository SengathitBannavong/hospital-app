import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
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
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: goToIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_hospital_outlined),
            selectedIcon: const Icon(Icons.local_hospital_rounded),
            label: context.l10n.navUtilities,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded),
            label: context.l10n.navMap,
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
            label: context.l10n.navChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.l10n.navProfile,
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
