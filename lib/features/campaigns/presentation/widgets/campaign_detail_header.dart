import 'package:flutter/material.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';

class CampaignDetailHeader extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailHeader({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(campaign.status);
    final statusText = _getStatusText(campaign.status);
    final iconColor = _getIconColor(campaign.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.campaign,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.campaignName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Aggiornato 10m fa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return Colors.green;
      case 'PAUSED':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return 'Attiva';
      case 'PAUSED':
        return 'In Pausa';
      default:
        return status;
    }
  }

  Color _getIconColor(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return Colors.green;
      case 'PAUSED':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}