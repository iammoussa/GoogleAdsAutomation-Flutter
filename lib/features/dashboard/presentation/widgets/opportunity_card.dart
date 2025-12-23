import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpportunityCard extends StatelessWidget {
  final String badge;
  final IconData badgeIcon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback? onDismiss;
  final bool showDismissButton;

  const OpportunityCard({
    super.key,
    required this.badge,
    required this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    this.onDismiss,
    this.showDismissButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeIcon,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Button
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),

          // Dismiss button (X)
          if (showDismissButton)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Manager for OpportunityCard dismissal state
class OpportunityCardManager {
  static const String _keyPrefix = 'opportunity_card_dismissed_';

  // Debug mode - always show cards regardless of dismissal
  static bool debugAlwaysShow = false;

  // Check if a card is dismissed
  static Future<bool> isDismissed(String cardId) async {
    if (debugAlwaysShow) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$cardId') ?? false;
  }

  // Dismiss a card
  static Future<void> dismiss(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$cardId', true);
  }

  // Show a card again (useful for debug)
  static Future<void> show(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$cardId');
  }

  // Reset all dismissed cards (useful for debug)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}