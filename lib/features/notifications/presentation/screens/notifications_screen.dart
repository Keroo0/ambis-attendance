import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';
import '../../data/models/notification_preferences_model.dart';
import '../providers/notification_preferences_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF191C1E),
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191C1E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            tooltip: 'Pengaturan Notifikasi',
            onPressed: () => _showSettingsSheet(context, ref),
          ),
          async.whenOrNull(
            data: (list) {
              final unread = list.where((n) => !n.isRead).length;
              if (unread == 0) return null;
              return TextButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).markAllAsRead(),
                child: const Text(
                  'Tandai Semua',
                  style: TextStyle(
                    color: Color(0xFF006A63),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFC4C6D0)),
              const SizedBox(height: 12),
              const Text(
                'Gagal memuat notifikasi',
                style: TextStyle(color: Color(0xFF43474F), fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Color(0xFF006A63))),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 72,
                  color: Color(0xFFE6E8EA),
                ),
                itemBuilder: (_, i) {
                  final n = list[i];
                  return _NotificationItem(
                    notification: n,
                    onTap: () => ref
                        .read(notificationsProvider.notifier)
                        .markAsRead(n.id),
                  )
                      .animate(key: ValueKey(n.id))
                      .fadeIn(delay: (50 * i).ms, duration: 250.ms);
                },
              ),
      ),
    );
  }
}

// ── Notification item ─────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case AppNotificationType.attendance:
        return Icons.fingerprint_rounded;
      case AppNotificationType.leave:
        return Icons.description_outlined;
      case AppNotificationType.grade:
        return Icons.school_outlined;
      case AppNotificationType.announcement:
        return Icons.campaign_outlined;
      case AppNotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case AppNotificationType.attendance:
        return const Color(0xFF16A34A);
      case AppNotificationType.leave:
        return const Color(0xFF006A63);
      case AppNotificationType.grade:
        return const Color(0xFF1E66F5);
      case AppNotificationType.announcement:
        return const Color(0xFFD97706);
      case AppNotificationType.system:
        return const Color(0xFF5B4300);
    }
  }

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '$weeks minggu lalu';
    final months = (diff.inDays / 30).floor();
    return '$months bulan lalu';
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead
            ? Colors.transparent
            : const Color(0xFF006A63).withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: const Color(0xFF191C1E),
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF006A63),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: const TextStyle(
                        color: Color(0xFF43474F), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: const TextStyle(
                        color: Color(0xFF747780), fontSize: 11),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: Color(0xFFC4C6D0)),
          SizedBox(height: 12),
          Text('Tidak ada notifikasi.',
              style: TextStyle(color: Color(0xFF43474F), fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Settings Sheet ────────────────────────────────────────────────────────────

class _NotificationSettingsSheet extends ConsumerWidget {
  const _NotificationSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC4C6D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 8),
            prefsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Gagal memuat pengaturan.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
              data: (prefs) => _SettingsList(prefs: prefs),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({required this.prefs});
  final NotificationPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final isSaving = ref.watch(notificationPreferencesProvider).isLoading;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Absensi'),
              subtitle: const Text('Konfirmasi absen masuk & pulang'),
              value: prefs.attendance,
              activeThumbColor: const Color(0xFF006A63),
              onChanged: isSaving
                  ? null
                  : (v) => notifier.save(prefs.copyWith(attendance: v)),
            ),
            SwitchListTile(
              title: const Text('Nilai'),
              subtitle: const Text('Pengumuman nilai baru'),
              value: prefs.grade,
              activeThumbColor: const Color(0xFF006A63),
              onChanged: isSaving
                  ? null
                  : (v) => notifier.save(prefs.copyWith(grade: v)),
            ),
            SwitchListTile(
              title: const Text('Izin'),
              subtitle: const Text('Status pengajuan izin/sakit'),
              value: prefs.leave,
              activeThumbColor: const Color(0xFF006A63),
              onChanged: isSaving
                  ? null
                  : (v) => notifier.save(prefs.copyWith(leave: v)),
            ),
            SwitchListTile(
              title: const Text('Pengumuman'),
              subtitle: const Text('Informasi dari sekolah'),
              value: prefs.announcement,
              activeThumbColor: const Color(0xFF006A63),
              onChanged: isSaving
                  ? null
                  : (v) => notifier.save(prefs.copyWith(announcement: v)),
            ),
            SwitchListTile(
              title: const Text('Sistem'),
              subtitle: const Text('Pembaruan & notifikasi sistem'),
              value: prefs.system,
              activeThumbColor: const Color(0xFF006A63),
              onChanged: isSaving
                  ? null
                  : (v) => notifier.save(prefs.copyWith(system: v)),
            ),
          ],
        ),
        if (isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
