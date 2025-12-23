import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String userName;
  final String? greeting;
  final String? avatarUrl;
  final bool showNotification;
  final int? notificationCount;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onAvatarPressed;
  final Color? avatarBackgroundColor;
  final Color? notificationBadgeColor;
  final EdgeInsets? padding;

  const UserHeader({
    super.key,
    required this.userName,
    this.greeting,
    this.avatarUrl,
    this.showNotification = true,
    this.notificationCount,
    this.onNotificationPressed,
    this.onAvatarPressed,
    this.avatarBackgroundColor,
    this.notificationBadgeColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onAvatarPressed,
            child: CircleAvatar(
              radius: 24,
              backgroundColor:
              avatarBackgroundColor ?? Colors.blue.shade100,
              backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.blue)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (greeting != null) ...[
                  Text(
                    greeting!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell
          if (showNotification) ...[
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: onNotificationPressed,
                ),
                if (notificationCount != null && notificationCount! > 0) ...[
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: notificationBadgeColor ?? Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount! > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ] else if (notificationCount == null) ...[
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: notificationBadgeColor ?? Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}