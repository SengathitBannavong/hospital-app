// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/services/version_gate.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/medical_info_card.dart';
import '../../../../core/widgets/fade_slide_transition.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../device/presentation/providers/asset_providers.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/widgets/notification_badge.dart';
import '../../../util/data/models/weather.dart';
import '../../../util/presentation/providers/util_providers.dart';
import '../../data/home_repository.dart';
import '../widgets/logout_sheet.dart';
import '../widgets/map_preview_card.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _homeRepository = HomeRepository();
  int _taskCount = 0;
  bool _isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
      if (mounted) {
        checkAndPrompt(context);
      }
    });
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoadingTasks = true);
    try {
      final tasks = await _homeRepository.getTasks();
      if (mounted) setState(() => _taskCount = tasks.length);
    } catch (error) {
      if (mounted) {
        AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }

  Future<void> _refreshHome() async {
    ref.invalidate(weatherProvider);
    await _fetchTasks();
  }

  Future<void> _logout() async {
    await showLogoutSheet(
      context,
      onConfirm: () async {
        await ref.read(authStateProvider.notifier).logout();
        if (mounted) AppToast.showSuccess(context.l10n.homeLoggedOut);
      },
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'refresh':
        if (!_isLoadingTasks) {
          await _refreshHome();
        }
        break;
      case 'settings':
        if (mounted) context.push('/settings');
        break;
      case 'logout':
        await _logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    final notifState = ref.watch(notificationProvider);
    final weather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeTitle),
        actions: [
          Semantics(
            button: true,
            label: context.l10n.homeOpenNotifications,
            child: IconButton(
              icon: const NotificationBadge(
                top: -6,
                right: -6,
                child: Icon(Icons.notifications_outlined),
              ),
              tooltip: context.l10n.homeNotificationsTitle,
              onPressed: () => context.push('/notification'),
            ),
          ),
          Semantics(
            button: true,
            label: context.l10n.homeOpenMenu,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: context.l10n.homeMenu,
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'refresh',
                  enabled: !_isLoadingTasks,
                  child: Semantics(
                    label: context.l10n.homeReloadHome,
                    child: Row(
                      children: [
                        const Icon(Icons.refresh_rounded),
                        const SizedBox(width: AppSpacing.sm),
                        Text(context.l10n.homeReload),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Semantics(
                    label: context.l10n.homeOpenSettings,
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined),
                        const SizedBox(width: AppSpacing.sm),
                        Text(context.l10n.settingsTitle),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Semantics(
                    label: context.l10n.homeLogoutAccount,
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded),
                        const SizedBox(width: AppSpacing.sm),
                        Text(context.l10n.settingsLogout),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const MapPreviewCard(),
              const _ActiveBookingCard(),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: Text(
                  context.l10n.homeQuickAccess,
                  style: context.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: context.l10n.homeActionQueue,
                            icon: Icons.people_outline,
                            onTap: () => context.push('/medical/queue'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionCard(
                            title: context.l10n.homeActionFindWheelchair,
                            icon: Icons.accessible_rounded,
                            onTap: () => context.push('/asset/search'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: context.l10n.homeActionSupport,
                            icon: Icons.support_agent_rounded,
                            onTap: () => context.push('/staff'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionCard(
                            title: context.l10n.homeActionPrescription,
                            icon: Icons.receipt_long,
                            onTap: () => context.push('/medical/prescription'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: 'SOS',
                            icon: Icons.emergency_rounded,
                            color: AppColors.emergency,
                            onTap: () => context.push('/sos'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: context.l10n.homeActionDeviceStations,
                            icon: Icons.local_parking_rounded,
                            onTap: () => context.push('/asset/stations'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  context.l10n.homeOverview,
                  style: context.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: MedicalInfoCard(
                  label: context.l10n.homeCurrentTasks,
                  value: _isLoadingTasks
                      ? context.l10n.commonLoading
                      : context.l10n.homeTasksActive(_taskCount),
                  icon: Icons.assignment_rounded,
                  onTap: () => context.go('/medical'),
                ),
              ),
              weather.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: _WeatherLoadingCard(),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (item) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _WeatherSummaryCard(weather: item),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  context.l10n.homeNotificationsTitle,
                  style: context.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        unreadCount > 0
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_outlined,
                        color: context.colorScheme.primary,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: context.colorScheme.error,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: TextStyle(
                                color: context.colorScheme.onError,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    notifState.isLoading
                        ? context.l10n.homeNotificationsLoading
                        : unreadCount > 0
                        ? context.l10n.homeNotificationsUnread(unreadCount)
                        : context.l10n.homeNotificationsNone,
                  ),
                  subtitle: Text(context.l10n.homeNotificationsTapToView),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () => context.push('/notification'),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              context.l10n.homeLoadingWeather,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherSummaryCard extends StatelessWidget {
  const _WeatherSummaryCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final description = weather.descriptions.isEmpty
        ? context.l10n.homeWeatherCurrent
        : weather.descriptions.first;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: context.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.city} • ${weather.tempC.round()}°C',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.homeWeatherDetail(
                      description,
                      weather.humidity,
                      weather.windSpeed.round(),
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
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

class _ActiveBookingCard extends ConsumerWidget {
  const _ActiveBookingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(activeBookingProvider);

    // No active booking: a muted hint that keeps the wheelchair flow visible
    // and one tap from search, instead of hiding the surface entirely.
    if (booking == null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Card(
          child: ListTile(
            leading: Icon(
              Icons.accessible_rounded,
              color: context.colorScheme.onSurfaceVariant,
            ),
            title: Text(context.l10n.homeNoBooking),
            subtitle: Text(context.l10n.homeNoBookingSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push('/asset/my'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Card(
        color: context.colorScheme.primaryContainer,
        child: Padding(
          padding: AppSpacing.cardPaddingLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.push('/asset/my'),
                child: Row(
                  children: [
                    Icon(
                      Icons.accessible_rounded,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.l10n.homeActiveBooking(booking.assetId),
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/asset/track/${booking.assetId}'),
                      icon: const Icon(Icons.location_on_outlined, size: 18),
                      label: Text(context.l10n.homeTrack),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/asset/book/${booking.assetId}'),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(context.l10n.homeReturnDevice),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? context.colorScheme.primary;
    return Card(
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  style: context.textTheme.labelLarge?.copyWith(color: color),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
