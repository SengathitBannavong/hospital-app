import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/features/chat/data/models/chat_room.dart';
import 'package:hospital_app/features/chat/presentation/providers/chat_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  StreamSubscription<ChatRoom>? _newMessageSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _newMessageSub = ref
          .read(chatRoomsProvider.notifier)
          .newMessageRooms
          .listen(_showNewMessageBanner);
    });
  }

  @override
  void dispose() {
    _newMessageSub?.cancel();
    super.dispose();
  }

  void _showNewMessageBanner(ChatRoom room) {
    if (!mounted) return;
    if (ref.read(activeChatRoomProvider) == room.id) return;
    if (_isCurrentChatRoom(room.id)) return;

    final messenger = ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text('Tin nhắn mới từ ${room.name}'),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              context.push('/chat/${room.id}', extra: {'room_name': room.name});
            },
            child: const Text('Mở'),
          ),
        ],
      ),
    );
  }

  bool _isCurrentChatRoom(int roomId) {
    final path = GoRouter.of(context).routeInformationProvider.value.uri.path;
    return path == '/chat/$roomId';
  }

  @override
  Widget build(BuildContext context) {
    final chatUnread = ref.watch(chatUnreadTotalProvider);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital_rounded),
            label: 'Y tế',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Bản đồ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: chatUnread > 0,
              label: Text(chatUnread > 99 ? '99+' : '$chatUnread'),
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: chatUnread > 0,
              label: Text(chatUnread > 99 ? '99+' : '$chatUnread'),
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
