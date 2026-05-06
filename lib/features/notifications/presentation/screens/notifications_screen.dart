import 'package:flutter/material.dart';

import '../../data/dummy_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<bool> _readStates;

  @override
  void initState() {
    super.initState();
    _readStates = kDummyNotifications.map((n) => n.isRead).toList();
  }

  int get _unreadCount => _readStates.where((r) => !r).length;

  void _markAllRead() =>
      setState(() => _readStates = List.filled(_readStates.length, true));

  @override
  Widget build(BuildContext context) {
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
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Tandai Semua',
                style: TextStyle(
                  color: Color(0xFF006A63),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: kDummyNotifications.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kDummyNotifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                color: Color(0xFFE6E8EA),
              ),
              itemBuilder: (_, i) => _NotificationItem(
                notification: kDummyNotifications[i],
                isRead: _readStates[i],
                onTap: () => setState(() => _readStates[i] = true),
              ),
            ),
    );
  }
}

// ── Notification item ─────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  final DummyNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.attendance:
        return Icons.fingerprint_rounded;
      case NotificationType.leave:
        return Icons.description_outlined;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.attendance:
        return const Color(0xFF16A34A);
      case NotificationType.leave:
        return const Color(0xFF006A63);
      case NotificationType.system:
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
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
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
                    _timeAgo(notification.time),
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
