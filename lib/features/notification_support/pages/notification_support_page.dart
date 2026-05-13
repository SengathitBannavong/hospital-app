import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'notification_providers.dart';

class NotificationSupportPage extends ConsumerStatefulWidget {
  const NotificationSupportPage({super.key});

  @override
  ConsumerState<NotificationSupportPage> createState() => _NotificationSupportPageState();
}

class _NotificationSupportPageState extends ConsumerState<NotificationSupportPage> {
  bool _isActionLoading = false;

  // Hàm xử lý SOS (SOS Logic)
  Future<void> _handleCreateSos() async {
    setState(() => _isActionLoading = true);
    try {
      await ref.read(notificationSupportServiceProvider).createSos(
        note: "Yêu cầu SOS từ ứng dụng di động",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi tín hiệu SOS thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi SOS thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // Hàm xử lý Chat (Chat Logic - Sắp ra mắt)
  Future<void> _handleCreateChat() async {
    setState(() => _isActionLoading = true);
    try {
      // Gọi API để tạo phòng
      await ref.read(notificationSupportServiceProvider).createChatRoom(null);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng Chat: Sắp ra mắt! (Đã tạo phòng API)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng Chat: Sắp ra mắt!')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo & Hỗ trợ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thông báo', icon: Icon(Icons.notifications)),
              Tab(text: 'Hỗ trợ', icon: Icon(Icons.support_agent)),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                // Tab 1: Danh sách thông báo (Notifications List)
                notifAsync.when(
                  data: (data) => ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: data.notifications.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = data.notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isRead 
                              ? context.colorScheme.outlineVariant 
                              : context.colorScheme.primaryContainer,
                          child: Icon(
                            item.notifType == 'reminder' ? Icons.event : Icons.info,
                            color: item.isRead 
                                ? context.colorScheme.onSurfaceVariant 
                                : context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(item.content),
                        trailing: Text(
                          item.createdAt.length >= 16 ? item.createdAt.substring(11, 16) : '', // Hiển thị giờ HH:mm
                          style: context.textTheme.labelSmall,
                        ),
                        onTap: () {
                          if (!item.isRead) {
                            ref.read(notificationSupportServiceProvider).setRead(item.notifId);
                            ref.invalidate(notificationsProvider);
                          }
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Lỗi: $err')),
                ),

                // Tab 2: Hỗ trợ (SOS & Chat Support)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút SOS
                      SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: ElevatedButton.icon(
                          onPressed: _handleCreateSos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderLg,
                            ),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded, size: 32),
                          label: const Text(
                            'Gửi hỗ trợ khẩn cấp (SOS)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Nút Chat Support
                      SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: OutlinedButton.icon(
                          onPressed: _handleCreateChat,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.borderLg,
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 32),
                          label: const Text(
                            'Trò chuyện với nhân viên (Chat)',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'Nhân viên sẵn sàng hỗ trợ bạn 24/7',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isActionLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
